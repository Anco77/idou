import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../common/quantity_selector.dart';
import 'package:idou/core/database/daos/inventory_dao.dart';
import '../../providers/inventory_providers.dart';

class ColorDetailPage extends ConsumerWidget {
  final int colorId;
  const ColorDetailPage({super.key, required this.colorId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(inventoryStateProvider);
    final notifier = ref.read(inventoryStateProvider.notifier);
    final logsAsync = ref.watch(colorLogsProvider(colorId));
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
        title: Text('${item.mardId} ${item.colorName}'),
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
                    if (qty == null || !context.mounted) return;
                    final success = await notifier.consume(colorId, qty);
                    if (!success && context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('库存不足，无法消耗')),
                      );
                    }
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
                    if (qty == null || !context.mounted) return;
                    await notifier.restock(colorId, qty);
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
                  _InfoRow('色号', item.mardId),
                  _InfoRow('名称', item.colorName),
                  _InfoRow('HEX', item.hexValue),
                  _InfoRow('RGB', '(${item.r}, ${item.g}, ${item.b})'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // 操作记录
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('操作记录', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  logsAsync.when(
                    data: (logs) {
                      if (logs.isEmpty) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          child: Center(
                            child: Text('暂无操作记录', style: TextStyle(color: Colors.grey)),
                          ),
                        );
                      }
                      return Column(
                        children: logs.map((log) => _LogRow(log: log)).toList(),
                      );
                    },
                    loading: () => const Center(
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                    error: (e, _) => Text('加载失败', style: TextStyle(color: Colors.red[400])),
                  ),
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

String _smartTime(DateTime dt) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final yesterday = today.subtract(const Duration(days: 1));
  final date = DateTime(dt.year, dt.month, dt.day);
  final hh = dt.hour.toString().padLeft(2, '0');
  final mm = dt.minute.toString().padLeft(2, '0');
  final time = '$hh:$mm';
  if (date == today) return time;
  if (date == yesterday) return '昨天 $time';
  return '${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')} $time';
}

class _LogRow extends StatelessWidget {
  final InventoryLogItem log;
  const _LogRow({required this.log});

  String get _typeLabel {
    switch (log.changeType) {
      case 'init':
        return '初始化';
      case 'restock':
        return '补货';
      case 'consume':
        return '消耗';
      case 'deduct_pattern':
        return '图纸扣除';
      default:
        return log.changeType;
    }
  }

  Color get _typeColor {
    switch (log.changeType) {
      case 'init':
        return Colors.blue;
      case 'restock':
        return Colors.green;
      case 'consume':
      case 'deduct_pattern':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData get _typeIcon {
    switch (log.changeType) {
      case 'init':
        return Icons.playlist_add_check;
      case 'restock':
        return Icons.add_circle_outline;
      case 'consume':
        return Icons.remove_circle_outline;
      case 'deduct_pattern':
        return Icons.auto_awesome;
      default:
        return Icons.info_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(_typeIcon, size: 18, color: _typeColor),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _typeLabel,
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 13,
                    color: _typeColor,
                  ),
                ),
                Text(
                  _smartTime(log.createdAt),
                  style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                ),
              ],
            ),
          ),
          Text(
            log.quantity > 0 ? '+${log.quantity}' : '${log.quantity}',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: log.quantity > 0 ? Colors.green : Colors.red,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '→ ${log.resultQty}',
            style: TextStyle(fontSize: 13, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }
}
