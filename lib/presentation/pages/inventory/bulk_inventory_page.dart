import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../common/quantity_selector.dart';
import 'package:idou/core/database/daos/inventory_dao.dart';
import '../../providers/inventory_providers.dart';

class BulkInventoryPage extends ConsumerStatefulWidget {
  const BulkInventoryPage({super.key});

  @override
  ConsumerState<BulkInventoryPage> createState() => _BulkInventoryPageState();
}

class _BulkInventoryPageState extends ConsumerState<BulkInventoryPage> {
  final Set<int> _selectedColorIds = {};
  final Set<String> _expandedSeries = {};

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
    final state = ref.watch(inventoryStateProvider);
    final notifier = ref.read(inventoryStateProvider.notifier);
    final grouped = state.groupedItems;

    return Scaffold(
      appBar: AppBar(title: const Text('批量操作')),
      body: grouped.isEmpty
          ? const Center(child: Text('没有数据'))
          : ListView(
              padding: const EdgeInsets.only(bottom: 80),
              children: [
                for (final series in seriesOrder)
                  if (grouped.containsKey(series))
                    _buildSeriesSection(series, grouped[series]!),
              ],
            ),
      bottomNavigationBar: _selectedColorIds.isEmpty
          ? null
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _batchAction(notifier, 'consume'),
                        icon: const Icon(Icons.remove_circle_outline),
                        label: Text('消耗 (${_selectedColorIds.length})'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: () => _batchAction(notifier, 'restock'),
                        icon: const Icon(Icons.add_circle_outline),
                        label: Text('补货 (${_selectedColorIds.length})'),
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildSeriesSection(String series, List<InventoryWithColor> items) {
    final isExpanded = _expandedSeries.contains(series);
    final color = _seriesColor(series);
    final selectedInSeries = items.where((i) => _selectedColorIds.contains(i.colorId)).length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: () {
            setState(() {
              if (isExpanded) {
                _expandedSeries.remove(series);
              } else {
                _expandedSeries.add(series);
              }
            });
          },
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
                if (selectedInSeries > 0) ...[
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '已选$selectedInSeries',
                      style: TextStyle(fontSize: 10, color: Colors.blue[600]),
                    ),
                  ),
                ],
                const Spacer(),
                if (!isExpanded)
                  Icon(Icons.chevron_right, color: Colors.grey[400]),
                if (isExpanded)
                  Icon(Icons.expand_more, color: Colors.grey[400]),
              ],
            ),
          ),
        ),
        if (isExpanded)
          ...items.map((item) => _buildColorTile(item)),
        const Divider(height: 1, indent: 12, endIndent: 12),
      ],
    );
  }

  Widget _buildColorTile(InventoryWithColor item) {
    final isSelected = _selectedColorIds.contains(item.colorId);
    final color = Color.fromARGB(255, item.r, item.g, item.b);

    return CheckboxListTile(
      dense: true,
      value: isSelected,
      onChanged: (v) {
        setState(() {
          if (v == true) {
            _selectedColorIds.add(item.colorId);
          } else {
            _selectedColorIds.remove(item.colorId);
          }
        });
      },
      secondary: Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: Colors.grey.shade300),
        ),
      ),
      title: Text(
        '#${item.colorId.toString().padLeft(3, '0')} ${item.colorName}',
        style: const TextStyle(fontSize: 13),
      ),
      subtitle: Text(
        '库存: ${item.currentQty}',
        style: TextStyle(
          fontSize: 11,
          color: item.isLowStock ? Colors.red : Colors.grey[600],
        ),
      ),
    );
  }

  Future<void> _batchAction(InventoryStateNotifier notifier, String action) async {
    if (_selectedColorIds.isEmpty) return;

    final qty = await QuantitySelector.show(
      context,
      title: action == 'restock' ? '批量补货数量' : '批量消耗数量',
    );
    if (qty == null || qty <= 0) return;

    final label = action == 'restock' ? '补货' : '消耗';
    final messenger = ScaffoldMessenger.of(context);

    for (final colorId in _selectedColorIds) {
      if (action == 'restock') {
        await notifier.restock(colorId, qty);
      } else {
        await notifier.consume(colorId, qty);
      }
    }

    if (context.mounted) {
      setState(() => _selectedColorIds.clear());
      messenger.showSnackBar(
        SnackBar(content: Text('已${label}${_selectedColorIds.length}个色号，每个$qty颗')),
      );
    }
  }
}
