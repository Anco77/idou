import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart' show Share, XFile;
import '../../common/update_dialog.dart';
import '../../../core/services/app_update_service.dart';
import '../../providers/inventory_providers.dart';
import '../../providers/settings_providers.dart';
import '../../providers/update_providers.dart';
import '../../theme/app_colors.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(inventoryStateProvider);
    final items = state.items;
    final totalColors = items.length;
    final totalBeads = items.fold<int>(0, (s, i) => s + i.currentQty);
    final lowCount = state.lowStockItems.length;

    // Series breakdown
    final seriesMap = <String, int>{};
    for (final item in items) {
      seriesMap.update(item.series, (v) => v + item.currentQty, ifAbsent: () => item.currentQty);
    }
    final maxSeriesQty = seriesMap.values.isEmpty ? 1 : seriesMap.values.reduce((a, b) => a > b ? a : b);

    return Scaffold(
      appBar: AppBar(
        title: const Text('我的'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 用户信息卡片
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: AppColors.primary,
                    child: const Icon(Icons.face, size: 36, color: Colors.white),
                  ),
                  const SizedBox(width: 16),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('idou 用户', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      Text('智能拼豆工具', style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // 库存概览
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('库存概览', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _StatItem2('色号数', '$totalColors'),
                      _StatItem2('总库存', '$totalBeads'),
                      _StatItem2('低量', '$lowCount',
                          color: lowCount > 0 ? AppColors.warning : AppColors.success),
                    ],
                  ),
                  if (seriesMap.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    const Divider(height: 1),
                    const SizedBox(height: 8),
                    ...seriesMap.entries.map((e) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 3),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 28,
                            child: Text(e.key, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(3),
                              child: Container(
                                height: 16,
                                color: Colors.grey.shade200,
                                alignment: Alignment.centerLeft,
                                child: FractionallySizedBox(
                                  widthFactor: (e.value / maxSeriesQty).clamp(0.0, 1.0),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          AppColors.primary.withValues(alpha: 0.4),
                                          AppColors.primary,
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text('${e.value}', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                        ],
                      ),
                    )),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // 功能设置
          Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Text('设置', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
                Consumer(builder: (context, ref, _) {
                  final themeMode = ref.watch(themeModeProvider);
                  return ListTile(
                    leading: const Icon(Icons.dark_mode, color: AppColors.primary),
                    title: const Text('深色模式'),
                    trailing: Switch(
                      value: themeMode == ThemeMode.dark,
                      onChanged: (v) {
                        ref.read(userSettingsProvider.notifier).setThemeMode(
                          v ? ThemeMode.dark : ThemeMode.light,
                        );
                      },
                    ),
                  );
                }),
                const Divider(height: 1),
                _SettingsTile(
                  icon: Icons.trending_up,
                  title: '低量预警阈值',
                  subtitle: (ref) => '当前 ${ref.watch(userSettingsProvider).lowStockThreshold} 颗',
                  onTap: (ctx, ref) => _editThreshold(ctx, ref),
                ),
                const Divider(height: 1),
                _SettingsTile(
                  icon: Icons.add_shopping_cart,
                  title: '默认补货数量',
                  subtitle: (ref) => '当前 ${ref.watch(userSettingsProvider).defaultRestockQty} 颗',
                  onTap: (ctx, ref) => _editRestockQty(ctx, ref),
                ),
                const Divider(height: 1),
                _SettingsTile(
                  icon: Icons.file_download,
                  title: '导出库存数据',
                  subtitle: (_) => '导出为 JSON 文件',
                  onTap: (ctx, ref) => _exportData(ctx, ref),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.restart_alt, color: AppColors.primary),
                  title: const Text('初始化库存'),
                  subtitle: const Text('将所有色号库存重置为指定数量'),
                  onTap: () => _showInitDialog(context, ref),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.cleaning_services, color: AppColors.primary),
                  title: const Text('清空所有库存数据'),
                  subtitle: const Text('清空所有色号数量和操作记录'),
                    onTap: () => _showClearDialog(context, ref),
                ),
                const Divider(height: 1),
                Consumer(builder: (context, ref, _) {
                  final versionAsync = ref.watch(currentVersionProvider);
                  final version = versionAsync.valueOrNull ?? '1.0.0+1';
                  return ListTile(
                    leading: const Icon(Icons.info_outline, color: AppColors.primary),
                    title: const Text('关于'),
                    subtitle: Text('idou v$version — AI拼豆工具'),
                    trailing: const Icon(Icons.system_update, size: 20),
                    onTap: () => _checkUpdate(context, ref),
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _editThreshold(BuildContext context, WidgetRef ref) async {
    final current = ref.read(userSettingsProvider).lowStockThreshold;
    final controller = TextEditingController(text: '$current');
    final result = await showDialog<int>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('低量预警阈值'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: '低于此数量即视为低量'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('取消')),
          FilledButton(
            onPressed: () {
              final v = int.tryParse(controller.text);
              if (v != null && v > 0) Navigator.pop(ctx, v);
            },
            child: const Text('确认'),
          ),
        ],
      ),
    );
    if (result != null && context.mounted) {
      ref.read(userSettingsProvider.notifier).setLowStockThreshold(result);
    }
  }

  Future<void> _editRestockQty(BuildContext context, WidgetRef ref) async {
    final current = ref.read(userSettingsProvider).defaultRestockQty;
    final controller = TextEditingController(text: '$current');
    final result = await showDialog<int>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('默认补货数量'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: '每次补货的默认数量'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('取消')),
          FilledButton(
            onPressed: () {
              final v = int.tryParse(controller.text);
              if (v != null && v > 0) Navigator.pop(ctx, v);
            },
            child: const Text('确认'),
          ),
        ],
      ),
    );
    if (result != null && context.mounted) {
      ref.read(userSettingsProvider.notifier).setDefaultRestockQty(result);
    }
  }

  Future<void> _exportData(BuildContext context, WidgetRef ref) async {
    try {
      final state = ref.read(inventoryStateProvider);
      final data = state.items.map((i) => {
        'color_id': i.colorId,
        'mard_id': i.mardId,
        'color_name': i.colorName,
        'current_qty': i.currentQty,
        'total_consumed': i.totalConsumed,
      }).toList();
      final json = const JsonEncoder.withIndent('  ').convert(data);
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/idou_export_${DateTime.now().millisecondsSinceEpoch}.json');
      await file.writeAsString(json);
      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'idou 库存数据导出',
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('导出失败: $e')),
        );
      }
    }
  }

  Future<void> _checkUpdate(BuildContext context, WidgetRef ref) async {
    final service = ref.read(appUpdateServiceProvider);
    final result = await service.checkForUpdate();
    if (!context.mounted) return;

    switch (result) {
      case UpdateAvailable(:final info):
        await showDialog(
          context: context,
          builder: (ctx) => UpdateDialog(updateInfo: info),
        );
      case NoUpdate(:final latestVersion):
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('当前已是最新版本 v$latestVersion')),
        );
      case CheckFailed(:final message):
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: Colors.orange,
          ),
        );
    }
  }

  void _showInitDialog(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController(text: '1200');
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('初始化库存'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('将所有色号库存重置为指定数量，此操作不可撤销。'),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: '初始数量（颗）',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('取消')),
          FilledButton(
            onPressed: () {
              final qty = int.tryParse(controller.text) ?? 1200;
              if (qty <= 0) return;
              Navigator.pop(ctx);
              ref.read(inventoryStateProvider.notifier).initializeInventory(defaultQty: qty);
            },
            child: const Text('确认初始化'),
          ),
        ],
      ),
    );
  }

  void _showClearDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('清空所有库存数据'),
        content: const Text('将清空所有色号的库存数量和操作记录。\n此操作不可恢复，确定继续吗？'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('取消')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Navigator.pop(ctx);
              ref.read(inventoryStateProvider.notifier).clearAllData();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('所有库存数据已清空')),
              );
            },
            child: const Text('确认清空'),
          ),
        ],
      ),
    );
  }
}

class _SettingsTile extends ConsumerWidget {
  final IconData icon;
  final String title;
  final String Function(WidgetRef ref) subtitle;
  final void Function(BuildContext, WidgetRef) onTap;

  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary),
      title: Text(title),
      subtitle: Text(subtitle(ref)),
      onTap: () => onTap(context, ref),
    );
  }
}

class _StatItem2 extends StatelessWidget {
  final String label;
  final String value;
  final Color? color;

  const _StatItem2(this.label, this.value, {this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: color ?? (Theme.of(context).brightness == Brightness.dark ? Colors.white70 : Colors.black87),
            ),
          ),
          Text(label, style: TextStyle(fontSize: 12, color: Theme.of(context).brightness == Brightness.dark ? Colors.grey[400] : Colors.grey)),
        ],
      ),
    );
  }
}
