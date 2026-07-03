import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../common/update_dialog.dart';
import '../../providers/inventory_providers.dart';
import '../../providers/update_providers.dart';
import '../../theme/app_colors.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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

          // 数据统计
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('库存统计', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  _buildStatRow(ref),
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
                ListTile(
                  leading: const Icon(Icons.settings_backup_restore, color: AppColors.primary),
                  title: const Text('一键初始化库存'),
                  subtitle: const Text('将所有色号重置为1200颗'),
                  onTap: () => _showInitDialog(context, ref),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.color_lens, color: AppColors.primary),
                  title: const Text('色号标准库'),
                  subtitle: const Text('查看221色完整色号信息'),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('共 221 种标准色号')),
                    );
                  },
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

  Widget _buildStatRow(WidgetRef ref) {
    final state = ref.watch(inventoryStateProvider);
    final totalItems = state.items.length;
    final totalBeads = state.items.fold<int>(0, (s, i) => s + i.currentQty);
    final lowCount = state.lowStockItems.length;

    return Row(
      children: [
        _StatItem2('色号数', '$totalItems'),
        _StatItem2('总库存', '$totalBeads'),
        _StatItem2('低量', '$lowCount', color: lowCount > 0 ? AppColors.warning : AppColors.success),
      ],
    );
  }

  Future<void> _checkUpdate(BuildContext context, WidgetRef ref) async {
    final service = ref.read(appUpdateServiceProvider);
    final updateInfo = await service.checkForUpdate();
    if (!context.mounted) return;

    if (updateInfo != null) {
      await showDialog(
        context: context,
        builder: (ctx) => UpdateDialog(updateInfo: updateInfo),
      );
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('当前已是最新版本')),
        );
      }
    }
  }

  void _showInitDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('一键初始化库存'),
        content: const Text('将所有色号库存重置为 1200 颗？\n此操作将清空所有库存变更记录。'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('取消')),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              ref.read(inventoryStateProvider.notifier).initializeInventory();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('库存已重置为 1200 颗')),
              );
            },
            child: const Text('确认初始化'),
          ),
        ],
      ),
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
              color: color ?? Colors.black87,
            ),
          ),
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        ],
      ),
    );
  }
}
