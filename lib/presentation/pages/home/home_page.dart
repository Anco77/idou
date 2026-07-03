import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../common/low_stock_banner.dart';
import '../../common/update_dialog.dart';
import '../../providers/inventory_providers.dart';
import '../../providers/patterns_providers.dart';
import '../../providers/update_providers.dart';
import '../../theme/app_colors.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkUpdate());
  }

  Future<void> _checkUpdate() async {
    final service = ref.read(appUpdateServiceProvider);
    final updateInfo = await service.checkForUpdate();
    if (!mounted || updateInfo == null) return;

    await showDialog(
      context: context,
      builder: (ctx) => UpdateDialog(updateInfo: updateInfo),
    );
  }

  @override
  Widget build(BuildContext context) {
    final homeState = ref.watch(homeStateProvider);
    final inventoryNotifier = ref.read(inventoryStateProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('idou'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.read(homeStateProvider.notifier).loadHomeData(),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(homeStateProvider.notifier).loadHomeData(),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // 低量预警横幅
            LowStockBanner(
              count: homeState.lowStockCount,
              total: homeState.totalColors,
              onTap: () {
                inventoryNotifier.setSortMode(InventorySortMode.byRemaining);
                context.go('/inventory');
              },
            ),
            const SizedBox(height: 16),

            // 库存概况卡片
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '库存概况',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        _StatItem(
                          icon: Icons.palette_outlined,
                          label: '色号总数',
                          value: '${homeState.totalColors}',
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 16),
                        _StatItem(
                          icon: Icons.inventory_outlined,
                          label: '库存总量',
                          value: '${homeState.totalBeads}',
                          color: AppColors.info,
                        ),
                        const SizedBox(width: 16),
                        _StatItem(
                          icon: Icons.warning_amber_rounded,
                          label: '不足500',
                          value: '${homeState.lowStockCount}',
                          color: homeState.lowStockCount > 0
                              ? AppColors.warning
                              : AppColors.success,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // 快速操作
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '快速操作',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _QuickAction(
                          icon: Icons.upload_file,
                          label: '上传图纸',
                          onTap: () => context.go('/recognition/upload'),
                        ),
                        _QuickAction(
                          icon: Icons.auto_awesome,
                          label: 'AI生成',
                          onTap: () => context.go('/ai-generate'),
                        ),
                        _QuickAction(
                          icon: Icons.add_shopping_cart,
                          label: '补货',
                          onTap: () => context.go('/inventory'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // 最近图纸
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '最近图纸',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    if (homeState.recentPatterns.isEmpty)
                      const Padding(
                        padding: EdgeInsets.all(24),
                        child: Center(
                          child: Text('暂无图纸记录', style: TextStyle(color: Colors.grey)),
                        ),
                      )
                    else
                      ...homeState.recentPatterns.map((p) => ListTile(
                        leading: const Icon(Icons.image_outlined),
                        title: Text(p.title, maxLines: 1, overflow: TextOverflow.ellipsis),
                        subtitle: Text(p.uploadTime.toString().substring(0, 10)),
                        trailing: Icon(
                          p.isCompleted ? Icons.check_circle : Icons.pending,
                          color: p.isCompleted ? AppColors.success : Colors.orange,
                        ),
                        onTap: () => context.go('/patterns/detail/${p.id}'),
                      )),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 4),
          Text(value, style: TextStyle(
            fontSize: 20, fontWeight: FontWeight.bold, color: color,
          )),
          Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
        ],
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          children: [
            Icon(icon, size: 32, color: AppColors.primary),
            const SizedBox(height: 4),
            Text(label, style: const TextStyle(fontSize: 12)),
          ],
        ),
      ),
    );
  }
}
