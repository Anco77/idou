import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/database/daos/inventory_dao.dart';
import '../providers/inventory_providers.dart';

class RestockResult {
  final int colorId;
  final int quantity;
  const RestockResult({required this.colorId, required this.quantity});
}

class RestockDialog extends ConsumerStatefulWidget {
  const RestockDialog({super.key});

  static Future<RestockResult?> show(BuildContext context) {
    return showDialog(
      context: context,
      builder: (ctx) => const RestockDialog(),
    );
  }

  @override
  ConsumerState<RestockDialog> createState() => _RestockDialogState();
}

class _RestockDialogState extends ConsumerState<RestockDialog> {
  String? _selectedSeries;
  InventoryWithColor? _selectedColor;
  final _qtyController = TextEditingController(text: '100');

  @override
  void dispose() {
    _qtyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(inventoryStateProvider);
    final grouped = state.groupedItems;

    final seriesList = seriesOrder.where((s) => grouped.containsKey(s)).toList();
    final colorsInSeries = <InventoryWithColor>[];
    if (_selectedSeries != null && grouped.containsKey(_selectedSeries)) {
      colorsInSeries.addAll(grouped[_selectedSeries]!);
      colorsInSeries.sort((a, b) => a.colorId.compareTo(b.colorId));
    }

    return AlertDialog(
      title: const Text('补货'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DropdownButtonFormField<String>(
            value: _selectedSeries,
            decoration: const InputDecoration(
              labelText: '选择色号系列',
              border: OutlineInputBorder(),
            ),
            items: seriesList.map((s) => DropdownMenuItem(
              value: s,
              child: Text('${s} · ${seriesNames[s] ?? ""}'),
            )).toList(),
            onChanged: (v) {
              setState(() {
                _selectedSeries = v;
                _selectedColor = null;
              });
            },
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<InventoryWithColor>(
            value: _selectedColor,
            decoration: const InputDecoration(
              labelText: '选择色号',
              border: OutlineInputBorder(),
            ),
            items: colorsInSeries.map((c) => DropdownMenuItem(
              value: c,
              child: Row(
                children: [
                  Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: Color.fromARGB(255, c.r, c.g, c.b),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text('${c.mardId}'),
                ],
              ),
            )).toList(),
            onChanged: (v) => setState(() => _selectedColor = v),
          ),
          if (_selectedColor != null) ...[
            const SizedBox(height: 8),
            Text(
              '当前库存: ${_selectedColor!.currentQty} 颗',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
          const SizedBox(height: 12),
          TextField(
            controller: _qtyController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: '补货数量（颗）',
              border: OutlineInputBorder(),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('取消'),
        ),
        FilledButton(
          onPressed: _selectedColor != null && (int.tryParse(_qtyController.text) ?? 0) > 0
              ? () => Navigator.pop(context, RestockResult(
                  colorId: _selectedColor!.colorId,
                  quantity: int.parse(_qtyController.text),
                ))
              : null,
          child: const Text('确认补货'),
        ),
      ],
    );
  }
}
