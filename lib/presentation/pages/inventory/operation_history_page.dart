import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/database/daos/inventory_dao.dart';
import '../../providers/inventory_providers.dart';

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

class OperationHistoryPage extends ConsumerStatefulWidget {
  const OperationHistoryPage({super.key});

  @override
  ConsumerState<OperationHistoryPage> createState() => _OperationHistoryPageState();
}

class _OperationHistoryPageState extends ConsumerState<OperationHistoryPage> {
  String? _filterType;

  @override
  Widget build(BuildContext context) {
    final logsAsync = ref.watch(operationLogsProvider(_filterType));

    return Scaffold(
      appBar: AppBar(
        title: const Text('操作历史'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                _FilterChip(
                  label: '全部',
                  selected: _filterType == null,
                  onTap: () => setState(() => _filterType = null),
                ),
                const SizedBox(width: 8),
                _FilterChip(
                  label: '补货',
                  selected: _filterType == 'restock',
                  onTap: () => setState(() => _filterType = 'restock'),
                ),
                const SizedBox(width: 8),
                _FilterChip(
                  label: '消耗',
                  selected: _filterType == 'consume' || _filterType == 'deduct_pattern',
                  onTap: () => setState(() => _filterType = 'consume'),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: logsAsync.when(
              data: (logs) {
                if (logs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.history, size: 48, color: Colors.grey[300]),
                        const SizedBox(height: 12),
                        Text(
                          _filterType != null ? '没有符合条件的操作记录' : '暂无操作记录',
                          style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                        ),
                      ],
                    ),
                  );
                }
                return ListView.separated(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  itemCount: logs.length,
                  separatorBuilder: (_, __) => const Divider(height: 1, indent: 72, endIndent: 16),
                  itemBuilder: (context, index) {
                    final log = logs[index];
                    return _LogTile(log: log, onTap: () {
                      context.go('/inventory/detail/${log.colorId}');
                    });
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('加载失败: $e', style: const TextStyle(color: Colors.red))),
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _FilterChip({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: selected ? colorScheme.primaryContainer : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? colorScheme.primary.withValues(alpha: 0.3) : Colors.grey.shade300,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontWeight: selected ? FontWeight.bold : FontWeight.normal,
            fontSize: 13,
            color: selected ? colorScheme.primary : Colors.grey[700],
          ),
        ),
      ),
    );
  }
}

class _LogTile extends StatelessWidget {
  final OperationLogItem log;
  final VoidCallback onTap;

  const _LogTile({required this.log, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isConsume = log.changeType == 'consume' || log.changeType == 'deduct_pattern';
    final actionColor = isConsume ? Colors.red : Colors.green;
    final typeLabel = _typeLabel(log.changeType);
    final qtyColor = log.quantity > 0 ? Colors.green : Colors.red;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            Stack(
              alignment: Alignment.bottomRight,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Color.fromARGB(255, log.r, log.g, log.b),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.grey.shade300, width: 1.5),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 18,
                  height: 18,
                  decoration: BoxDecoration(
                    color: actionColor,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: Icon(
                    isConsume ? Icons.remove : Icons.add,
                    size: 10,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        log.mardId,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                        decoration: BoxDecoration(
                          color: actionColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          typeLabel,
                          style: TextStyle(
                            fontSize: 11,
                            color: actionColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    _smartTime(log.createdAt),
                    style: TextStyle(fontSize: 12, color: Colors.grey[400]),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  log.quantity > 0 ? '+${log.quantity}' : '${log.quantity}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: qtyColor,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '→ ${log.resultQty}',
                  style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                ),
              ],
            ),
            const SizedBox(width: 4),
            Icon(Icons.chevron_right, size: 18, color: Colors.grey[300]),
          ],
        ),
      ),
    );
  }

  String _typeLabel(String type) {
    switch (type) {
      case 'init': return '初始化';
      case 'restock': return '补货';
      case 'consume': return '消耗';
      case 'deduct_pattern': return '图纸扣除';
      case 'set': return '设置';
      default: return type;
    }
  }
}
