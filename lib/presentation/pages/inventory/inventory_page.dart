import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../common/color_card.dart';
import '../../common/low_stock_banner.dart';
import '../../common/quantity_selector.dart';
import '../../common/restock_dialog.dart';
import '../../providers/settings_providers.dart';
import '../../theme/app_colors.dart';
import '../../../core/database/daos/inventory_dao.dart';
import '../../providers/inventory_providers.dart';

class InventoryPage extends ConsumerStatefulWidget {
  const InventoryPage({super.key});

  @override
  ConsumerState<InventoryPage> createState() => _InventoryPageState();
}

class _InventoryPageState extends ConsumerState<InventoryPage> {
  final Set<String> _expandedSeries = {};
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(inventoryStateProvider);
    final notifier = ref.read(inventoryStateProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('库存管理'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_shopping_cart),
            tooltip: '补货',
            onPressed: () => _showRestockDialog(context, ref),
          ),
          IconButton(
            icon: const Icon(Icons.playlist_add),
            tooltip: '批量操作',
            onPressed: () => context.go('/inventory/bulk'),
          ),
          IconButton(
            icon: const Icon(Icons.history),
            tooltip: '操作历史',
            onPressed: () => context.go('/inventory/history'),
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
            total: state.items.length,
            threshold: ref.read(userSettingsProvider).lowStockThreshold,
            onTap: () {
              notifier.setSortMode(InventorySortMode.byRemaining);
            },
          ),
          _buildSearchBar(state, notifier),
          _buildStatsRow(state),
          const SizedBox(height: 4),
          Expanded(child: _buildSeriesList(state, notifier)),
        ],
      ),
    );
  }

  Widget _buildSearchBar(InventoryState state, InventoryStateNotifier notifier) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: '搜索色号或名称...',
                hintStyle: TextStyle(fontSize: 13, color: Colors.grey[400]),
                prefixIcon: const Icon(Icons.search, size: 20),
                suffixIcon: state.searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.close, size: 18),
                        onPressed: () {
                          _searchController.clear();
                          notifier.setSearchQuery('');
                        },
                      )
                    : null,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
              style: const TextStyle(fontSize: 13),
              onChanged: (v) => notifier.setSearchQuery(v),
            ),
          ),
          const SizedBox(width: 8),
          _SortChip(
            label: '色号',
            active: state.sortMode == InventorySortMode.byColorId,
            ascending: state.ascending,
            onTap: () => notifier.setSortMode(InventorySortMode.byColorId),
          ),
          const SizedBox(width: 4),
          _SortChip(
            label: '余量',
            active: state.sortMode == InventorySortMode.byRemaining,
            ascending: state.ascending,
            onTap: () => notifier.setSortMode(InventorySortMode.byRemaining),
          ),
          const SizedBox(width: 4),
          _SortChip(
            label: '消耗',
            active: state.sortMode == InventorySortMode.byConsumption,
            ascending: state.ascending,
            onTap: () => notifier.setSortMode(InventorySortMode.byConsumption),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow(InventoryState state) {
    final totalColors = state.items.length;
    final lowCount = state.lowStockItems.length;
    final totalQty = state.items.fold<int>(0, (sum, item) => sum + item.currentQty);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      child: Row(
        children: [
          _StatChip(label: '总色数', value: '$totalColors'),
          const SizedBox(width: 8),
          _StatChip(
            label: '低量',
            value: '$lowCount',
            color: lowCount > 0 ? AppColors.warning : null,
            onTap: lowCount > 0 ? () => _showLowStockSheet(context) : null,
          ),
          const SizedBox(width: 8),
          _StatChip(label: '总库存', value: '$totalQty'),
        ],
      ),
    );
  }

  void _showLowStockSheet(BuildContext context) {
    final state = ref.read(inventoryStateProvider);
    final lowItems = state.lowStockItems;
    if (lowItems.isEmpty) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Container(
        height: MediaQuery.of(ctx).size.height * 0.6,
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        child: Column(
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.warning_amber_rounded,
                    color: AppColors.warning, size: 22),
                const SizedBox(width: 8),
                const Text(
                  '低量色号',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 8),
                Text(
                  '${lowItems.length}色库存不足500颗',
                  style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  childAspectRatio: 0.75,
                  crossAxisSpacing: 6,
                  mainAxisSpacing: 6,
                ),
                itemCount: lowItems.length,
                itemBuilder: (ctx, i) => ColorCard(
                  item: lowItems[i],
                  onTap: () {
                    Navigator.pop(ctx);
                    context.go('/inventory/detail/${lowItems[i].colorId}');
                  },
                ),
              ),
            ),
          ],
        ),
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

    // 余量/消耗排序：扁平列表
    if (state.sortMode == InventorySortMode.byRemaining || state.sortMode == InventorySortMode.byConsumption) {
      return _buildFlatList(state);
    }

    final grouped = state.groupedItems;
    if (grouped.isEmpty) {
      return _buildEmptyState(state);
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
              onSetQty: (item) => _showSetQty(context, ref, item.colorId),
            ),
      ],
    );
  }

  Widget _buildFlatList(InventoryState state) {
    final items = state.filteredItems;
    if (items.isEmpty) {
      return _buildEmptyState(state);
    }

    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(8, 4, 8, 16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 0.75,
        crossAxisSpacing: 6,
        mainAxisSpacing: 6,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return ColorCard(
          item: item,
          showConsumption: state.sortMode == InventorySortMode.byConsumption,
          onTap: () => context.go('/inventory/detail/${item.colorId}'),
          onAdd: () => _showRestock(context, ref, item.colorId),
          onSubtract: () => _showConsume(context, ref, item.colorId),
          onSetQty: () => _showSetQty(context, ref, item.colorId),
        );
      },
    );
  }

  Widget _buildEmptyState(InventoryState state) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 48, color: Colors.grey[300]),
          const SizedBox(height: 12),
          Text(
            state.searchQuery.isNotEmpty ? '没有匹配的色号' : '暂无库存数据',
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  void _showRestock(BuildContext context, WidgetRef ref, int colorId) async {
    final defaultQty = ref.read(userSettingsProvider).defaultRestockQty;
    final qty = await QuantitySelector.show(context, title: '补货数量', initialValue: defaultQty);
    if (qty != null && qty > 0) {
      ref.read(inventoryStateProvider.notifier).restock(colorId, qty);
    }
  }

  Future<void> _showRestockDialog(BuildContext context, WidgetRef ref) async {
    final defaultQty = ref.read(userSettingsProvider).defaultRestockQty;
    final result = await RestockDialog.show(context, defaultQty: defaultQty);
    if (result != null && context.mounted) {
      ref.read(inventoryStateProvider.notifier).restock(result.colorId, result.quantity);
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

  void _showSetQty(BuildContext context, WidgetRef ref, int colorId) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('设置数量'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('将该色号库存数量设置为：'),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: '数量（颗）',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('取消')),
          FilledButton(
            onPressed: () {
              final qty = int.tryParse(controller.text);
              if (qty == null || qty < 0) return;
              Navigator.pop(ctx);
              ref.read(inventoryStateProvider.notifier).setQty(colorId, qty);
            },
            child: const Text('确认'),
          ),
        ],
      ),
    );
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
}

class _SeriesSection extends StatelessWidget {
  final String series;
  final List<InventoryWithColor> items;
  final bool isExpanded;
  final VoidCallback onToggle;
  final void Function(InventoryWithColor) onTapItem;
  final void Function(InventoryWithColor) onAdd;
  final void Function(InventoryWithColor) onSubtract;
  final void Function(InventoryWithColor) onSetQty;

  const _SeriesSection({
    required this.series,
    required this.items,
    required this.isExpanded,
    required this.onToggle,
    required this.onTapItem,
    required this.onAdd,
    required this.onSubtract,
    required this.onSetQty,
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
    final healthRatio = items.isEmpty ? 1.0 : 1.0 - (lowCount / items.length);
    final progressColor = healthRatio >= 0.9
        ? Colors.green
        : healthRatio >= 0.7
            ? Colors.orange
            : Colors.red;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [color.withValues(alpha: 0.06), Colors.transparent],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
          ),
          child: InkWell(
            onTap: onToggle,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: color,
                    child: Text(
                      series,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        seriesNames[series] ?? series,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                      const SizedBox(height: 3),
                      SizedBox(
                        width: 60,
                        height: 4,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(2),
                          child: LinearProgressIndicator(
                            value: healthRatio.clamp(0.0, 1.0),
                            backgroundColor: Colors.grey[200],
                            valueColor: AlwaysStoppedAnimation<Color>(progressColor),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 8),
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
                  AnimatedRotation(
                    turns: isExpanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: const Icon(Icons.expand_more, color: Colors.grey),
                  ),
                ],
              ),
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
                crossAxisCount: 3,
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
                  onSetQty: () => onSetQty(item),
                );
              },
            ),
          ),
        const Divider(height: 1, indent: 12, endIndent: 12),
      ],
    );
  }
}

class _SortChip extends StatelessWidget {
  final String label;
  final bool active;
  final bool ascending;
  final VoidCallback onTap;

  const _SortChip({
    required this.label,
    required this.active,
    required this.ascending,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: active ? colorScheme.primaryContainer : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: active
                ? colorScheme.primary.withValues(alpha: 0.3)
                : Colors.grey.shade300,
          ),
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
                color: colorScheme.primary,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final String value;
  final Color? color;
  final VoidCallback? onTap;

  const _StatChip({
    required this.label,
    required this.value,
    this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final chipColor = color ?? Colors.grey;
    final chip = Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: chipColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 11, color: Colors.grey[600]),
          ),
          const SizedBox(width: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: chipColor,
            ),
          ),
          if (onTap != null && color != null) ...[
            const SizedBox(width: 2),
            const Icon(Icons.chevron_right, size: 14),
          ],
        ],
      ),
    );

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: chip,
      );
    }
    return chip;
  }
}
