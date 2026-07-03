import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../common/color_card.dart';
import '../../common/low_stock_banner.dart';
import '../../common/quantity_selector.dart';
import '../../providers/inventory_providers.dart';

class InventoryPage extends ConsumerWidget {
  const InventoryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(inventoryStateProvider);
    final notifier = ref.read(inventoryStateProvider.notifier);
    final filtered = state.filteredItems;

    return Scaffold(
      appBar: AppBar(
        title: const Text('库存管理'),
        actions: [
          // 初始化按钮
          IconButton(
            icon: const Icon(Icons.settings_backup_restore),
            tooltip: '一键初始化',
            onPressed: () => _showInitDialog(context, ref),
          ),
        ],
      ),
      body: Column(
        children: [
          // 低量预警
          LowStockBanner(
            count: state.lowStockItems.length,
            onTap: () {
              notifier.setSortMode(InventorySortMode.byRemaining);
            },
          ),

          // 搜索栏 + 排序
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                // 搜索
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: '搜索色号或名称...',
                      prefixIcon: const Icon(Icons.search, size: 20),
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(vertical: 8),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onChanged: (v) => notifier.setSearchQuery(v),
                  ),
                ),
                const SizedBox(width: 8),
                // 排序按钮
                _SortButton(
                  label: '色号',
                  active: state.sortMode == InventorySortMode.byColorId,
                  ascending: state.ascending,
                  onTap: () => notifier.setSortMode(InventorySortMode.byColorId),
                ),
                const SizedBox(width: 4),
                _SortButton(
                  label: '余量',
                  active: state.sortMode == InventorySortMode.byRemaining,
                  ascending: state.ascending,
                  onTap: () => notifier.setSortMode(InventorySortMode.byRemaining),
                ),
              ],
            ),
          ),

          // 库存卡片网格
          Expanded(
            child: state.isLoading
                ? const Center(child: CircularProgressIndicator())
                : state.error != null
                    ? Center(child: Text('加载失败: ${state.error}'))
                    : filtered.isEmpty
                        ? const Center(child: Text('没有匹配的色号'))
                        : GridView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 4,
                              childAspectRatio: 0.75,
                              crossAxisSpacing: 6,
                              mainAxisSpacing: 6,
                            ),
                            itemCount: filtered.length,
                            itemBuilder: (context, index) {
                              final item = filtered[index];
                              return ColorCard(
                                item: item,
                                onTap: () => context.go('/inventory/detail/${item.colorId}'),
                                onAdd: () => _showRestock(context, ref, item.colorId),
                                onSubtract: () => _showConsume(context, ref, item.colorId),
                              );
                            },
                          ),
          ),
        ],
      ),
    );
  }

  void _showRestock(BuildContext context, WidgetRef ref, int colorId) async {
    final qty = await QuantitySelector.show(context, title: '补货数量');
    if (qty != null && qty > 0) {
      ref.read(inventoryStateProvider.notifier).restock(colorId, qty);
    }
  }

  void _showConsume(BuildContext context, WidgetRef ref, int colorId) async {
    final qty = await QuantitySelector.show(context, title: '消耗数量');
    if (qty != null && qty > 0) {
      ref.read(inventoryStateProvider.notifier).consume(colorId, qty);
    }
  }

  void _showInitDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('一键初始化库存'),
        content: const Text('将所有色号库存重置为 1200 颗？此操作不可撤销。'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('取消')),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              ref.read(inventoryStateProvider.notifier).initializeInventory();
            },
            child: const Text('确认初始化'),
          ),
        ],
      ),
    );
  }
}

class _SortButton extends StatelessWidget {
  final String label;
  final bool active;
  final bool ascending;
  final VoidCallback onTap;

  const _SortButton({
    required this.label,
    required this.active,
    required this.ascending,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: active ? Theme.of(context).colorScheme.primaryContainer : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontWeight: active ? FontWeight.bold : FontWeight.normal,
                fontSize: 12,
              ),
            ),
            if (active) ...[
              const SizedBox(width: 2),
              Icon(
                ascending ? Icons.arrow_upward : Icons.arrow_downward,
                size: 14,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
