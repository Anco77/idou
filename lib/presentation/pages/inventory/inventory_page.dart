import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../common/color_card.dart';
import '../../common/low_stock_banner.dart';
import '../../common/quantity_selector.dart';
import 'package:idou/core/database/daos/inventory_dao.dart';
import '../../providers/inventory_providers.dart';

class InventoryPage extends ConsumerStatefulWidget {
  const InventoryPage({super.key});

  @override
  ConsumerState<InventoryPage> createState() => _InventoryPageState();
}

class _InventoryPageState extends ConsumerState<InventoryPage> {
  final Set<String> _expandedSeries = {};

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(inventoryStateProvider);
    final notifier = ref.read(inventoryStateProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('库存管理'),
        actions: [
          IconButton(
            icon: const Icon(Icons.playlist_add),
            tooltip: '批量操作',
            onPressed: () => context.go('/inventory/bulk'),
          ),
          IconButton(
            icon: const Icon(Icons.settings_backup_restore),
            tooltip: '一键初始化',
            onPressed: () => _showInitDialog(context, ref),
          ),
        ],
      ),
      body: Column(
        children: [
          LowStockBanner(
            count: state.lowStockItems.length,
            onTap: () {
              notifier.setSortMode(InventorySortMode.byRemaining);
            },
          ),
          _buildSearchBar(state, notifier),
          Expanded(child: _buildSeriesList(state, notifier)),
        ],
      ),
    );
  }

  Widget _buildSearchBar(InventoryState state, InventoryStateNotifier notifier) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
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
    );
  }

  Widget _buildSeriesList(InventoryState state, InventoryStateNotifier notifier) {
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (state.error != null) {
      return Center(child: Text('加载失败: ${state.error}'));
    }

    final grouped = state.groupedItems;
    if (grouped.isEmpty) {
      return const Center(child: Text('没有匹配的色号'));
    }

    return ListView(
      padding: const EdgeInsets.only(bottom: 16),
      children: [
        for (final series in seriesOrder)
          if (grouped.containsKey(series))
            _SeriesSection(
              series: series,
              items: grouped[series]!,
              isExpanded: _expandedSeries.contains(series),
              onToggle: () {
                setState(() {
                  if (_expandedSeries.contains(series)) {
                    _expandedSeries.remove(series);
                  } else {
                    _expandedSeries.add(series);
                  }
                });
              },
              onTapItem: (item) => context.go('/inventory/detail/${item.colorId}'),
              onAdd: (item) => _showRestock(context, ref, item.colorId),
              onSubtract: (item) => _showConsume(context, ref, item.colorId),
            ),
      ],
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
      final success = await ref.read(inventoryStateProvider.notifier).consume(colorId, qty);
      if (!success && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('库存不足，无法消耗')),
        );
      }
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

class _SeriesSection extends StatelessWidget {
  final String series;
  final List<InventoryWithColor> items;
  final bool isExpanded;
  final VoidCallback onToggle;
  final void Function(InventoryWithColor) onTapItem;
  final void Function(InventoryWithColor) onAdd;
  final void Function(InventoryWithColor) onSubtract;

  const _SeriesSection({
    required this.series,
    required this.items,
    required this.isExpanded,
    required this.onToggle,
    required this.onTapItem,
    required this.onAdd,
    required this.onSubtract,
  });

  Color _seriesColor(String series) {
    switch (series) {
      case 'A': return const Color(0xFFFFC107);
      case 'B': return const Color(0xFF4CAF50);
      case 'C': return const Color(0xFF2196F3);
      case 'D': return const Color(0xFF9C27B0);
      case 'E': return const Color(0xFFE91E63);
      case 'F': return const Color(0xFFF44336);
      case 'G': return const Color(0xFF795548);
      case 'H': return const Color(0xFF607D8B);
      case 'M': return const Color(0xFF9E9E9E);
      default: return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _seriesColor(series);
    final lowCount = items.where((i) => i.isLowStock).length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: onToggle,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    series,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  seriesNames[series] ?? series,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
                const SizedBox(width: 6),
                Text(
                  '${items.length}色',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
                if (lowCount > 0) ...[
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '$lowCount低量',
                      style: TextStyle(fontSize: 10, color: Colors.red[600]),
                    ),
                  ),
                ],
                const Spacer(),
                Icon(
                  isExpanded ? Icons.expand_less : Icons.expand_more,
                  color: Colors.grey,
                ),
              ],
            ),
          ),
        ),
        if (isExpanded)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                childAspectRatio: 0.75,
                crossAxisSpacing: 6,
                mainAxisSpacing: 6,
              ),
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                return ColorCard(
                  item: item,
                  onTap: () => onTapItem(item),
                  onAdd: () => onAdd(item),
                  onSubtract: () => onSubtract(item),
                );
              },
            ),
          ),
        const Divider(height: 1, indent: 12, endIndent: 12),
      ],
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
