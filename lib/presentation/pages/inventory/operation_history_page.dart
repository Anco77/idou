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
  ConsumerState<OperationHistoryPage> createState() =>
      _OperationHistoryPageState();
}

class _OperationHistoryPageState extends ConsumerState<OperationHistoryPage> {
  static const _pageSize = 50;
  String? _filterType;
  int? _colorId;
  bool _recentOnly = false;
  final _colorController = TextEditingController();
  final List<OperationLogItem> _logs = [];
  bool _isLoading = true;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    Future.microtask(_reload);
  }

  @override
  void dispose() {
    _colorController.dispose();
    super.dispose();
  }

  Future<void> _reload() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final logs = await _fetch(0);
      if (!mounted) return;
      setState(() {
        _logs
          ..clear()
          ..addAll(logs);
        _hasMore = logs.length == _pageSize;
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error.toString();
        _isLoading = false;
      });
    }
  }

  Future<List<OperationLogItem>> _fetch(int offset) {
    return ref.read(inventoryServiceProvider).getAllLogs(
          changeType: _filterType,
          colorId: _colorId,
          from: _recentOnly
              ? DateTime.now().subtract(const Duration(days: 7))
              : null,
          limit: _pageSize,
          offset: offset,
        );
  }

  Future<void> _loadMore() async {
    if (_isLoadingMore || !_hasMore) return;
    setState(() => _isLoadingMore = true);
    try {
      final next = await _fetch(_logs.length);
      if (!mounted) return;
      setState(() {
        _logs.addAll(next);
        _hasMore = next.length == _pageSize;
      });
    } finally {
      if (mounted) setState(() => _isLoadingMore = false);
    }
  }

  void _setType(String? value) {
    if (_filterType == value) return;
    _filterType = value;
    _reload();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('操作历史'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(children: [
                _FilterChip(
                  label: '全部',
                  selected: _filterType == null,
                  onTap: () => _setType(null),
                ),
                const SizedBox(width: 8),
                _FilterChip(
                  label: '补货',
                  selected: _filterType == 'restock',
                  onTap: () => _setType('restock'),
                ),
                const SizedBox(width: 8),
                _FilterChip(
                  label: '消耗',
                  selected: _filterType == 'consume',
                  onTap: () => _setType('consume'),
                ),
                const SizedBox(width: 8),
                _FilterChip(
                  label: '图纸扣除',
                  selected: _filterType == 'deduct_pattern',
                  onTap: () => _setType('deduct_pattern'),
                ),
                const SizedBox(width: 8),
                _FilterChip(
                  label: '冲正',
                  selected: _filterType == 'reversal',
                  onTap: () => _setType('reversal'),
                ),
                const SizedBox(width: 8),
                _FilterChip(
                  label: '最近7天',
                  selected: _recentOnly,
                  onTap: () {
                    _recentOnly = !_recentOnly;
                    _reload();
                  },
                ),
              ]),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
            child: TextField(
              controller: _colorController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                isDense: true,
                hintText: '按内部色号筛选',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _colorId == null
                    ? null
                    : IconButton(
                        onPressed: () {
                          _colorController.clear();
                          _colorId = null;
                          _reload();
                        },
                        icon: const Icon(Icons.close),
                      ),
                border: const OutlineInputBorder(),
              ),
              onSubmitted: (value) {
                _colorId = int.tryParse(value.trim());
                _reload();
              },
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: _buildBody(),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(
        child: FilledButton.icon(
          onPressed: _reload,
          icon: const Icon(Icons.refresh),
          label: const Text('加载失败，点击重试'),
        ),
      );
    }
    if (_logs.isEmpty) {
      return Center(
        child: Text(
          _filterType != null || _colorId != null || _recentOnly
              ? '没有符合条件的操作记录'
              : '暂无操作记录',
        ),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 4),
      itemCount: _logs.length + (_hasMore ? 1 : 0),
      separatorBuilder: (_, __) =>
          const Divider(height: 1, indent: 72, endIndent: 16),
      itemBuilder: (context, index) {
        if (index == _logs.length) {
          return TextButton.icon(
            onPressed: _isLoadingMore ? null : _loadMore,
            icon: _isLoadingMore
                ? const SizedBox.square(
                    dimension: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.expand_more),
            label: const Text('加载更多'),
          );
        }
        final log = _logs[index];
        return _LogTile(
          log: log,
          onTap: () => log.patternId == null
              ? context.go('/inventory/detail/${log.colorId}')
              : context.go('/patterns/detail/${log.patternId}'),
          onReverse: log.changeType == 'deduct_pattern' && log.patternId != null
              ? () => _confirmReverse(log)
              : null,
        );
      },
    );
  }

  Future<void> _confirmReverse(OperationLogItem log) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('冲正图纸扣除'),
        content: Text('将 ${log.mardId} 的 ${-log.quantity} 颗库存加回。原流水会保留。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('确认冲正'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    final success = await ref.read(inventoryServiceProvider).reverseLog(log.id);
    if (!mounted) return;
    if (success) {
      await ref.read(inventoryStateProvider.notifier).loadInventory();
      await _reload();
    }
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(success ? '冲正成功，原流水已保留' : '该流水不可冲正或已经冲正')),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _FilterChip(
      {required this.label, required this.selected, required this.onTap});

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
            color: selected
                ? colorScheme.primary.withValues(alpha: 0.3)
                : Colors.grey.shade300,
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
  final VoidCallback? onReverse;

  const _LogTile({required this.log, required this.onTap, this.onReverse});

  @override
  Widget build(BuildContext context) {
    final isConsume =
        log.changeType == 'consume' || log.changeType == 'deduct_pattern';
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
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 1),
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
            if (onReverse != null)
              IconButton(
                onPressed: onReverse,
                tooltip: '冲正',
                icon: const Icon(Icons.undo),
              )
            else
              Icon(Icons.chevron_right, size: 18, color: Colors.grey[300]),
          ],
        ),
      ),
    );
  }

  String _typeLabel(String type) {
    switch (type) {
      case 'init':
        return '初始化';
      case 'restock':
        return '补货';
      case 'consume':
        return '消耗';
      case 'deduct_pattern':
        return '图纸扣除';
      case 'set':
        return '设置';
      case 'reversal':
        return '冲正';
      default:
        return type;
    }
  }
}
