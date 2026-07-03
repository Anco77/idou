import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../common/quantity_selector.dart';
import '../../providers/inventory_providers.dart';

class ColorDetailPage extends ConsumerWidget {
  final int colorId;
  const ColorDetailPage({super.key, required this.colorId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(inventoryStateProvider);
    final notifier = ref.read(inventoryStateProvider.notifier);
    final item = state.items.where((i) => i.colorId == colorId).firstOrNull;

    if (item == null) {
      return Scaffold(
        appBar: AppBar(title: Text('#${colorId.toString().padLeft(3, '0')}')),
        body: const Center(child: Text('未找到该色号')),
      );
    }

    final color = Color.fromARGB(255, item.r, item.g, item.b);

    return Scaffold(
      appBar: AppBar(
        title: Text('#${item.colorId.toString().padLeft(3, '0')} ${item.colorName}'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 色块展示
          Center(
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade300),
                boxShadow: [
                  BoxShadow(
                    color: color.withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // 当前库存
          Center(
            child: Column(
              children: [
                Text(
                  '${item.currentQty}',
                  style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: item.isLowStock ? Colors.red : Colors.black87,
                  ),
                ),
                Text('当前库存（颗）', style: TextStyle(color: Colors.grey[600])),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // 操作按钮
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () async {
                    final qty = await QuantitySelector.show(context, title: '消耗数量');
                    if (qty != null) notifier.consume(colorId, qty);
                  },
                  icon: const Icon(Icons.remove_circle_outline),
                  label: const Text('消耗'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: FilledButton.icon(
                  onPressed: () async {
                    final qty = await QuantitySelector.show(context, title: '补货数量');
                    if (qty != null) notifier.restock(colorId, qty);
                  },
                  icon: const Icon(Icons.add_circle_outline),
                  label: const Text('补货'),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // 颜色信息
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('颜色信息', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  _InfoRow('色号', '#${item.colorId.toString().padLeft(3, '0')}'),
                  _InfoRow('名称', item.colorName),
                  _InfoRow('HEX', item.hexValue),
                  _InfoRow('RGB', '(${item.r}, ${item.g}, ${item.b})'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 60,
            child: Text(label, style: const TextStyle(color: Colors.grey)),
          ),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
