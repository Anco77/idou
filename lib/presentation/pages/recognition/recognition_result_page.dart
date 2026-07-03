import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import '../../../core/database/daos/patterns_dao.dart';
import '../../../core/utils/color_matcher.dart';
import '../../../domain/services/pattern_recognition_service.dart';
import '../../providers/inventory_providers.dart';
import '../../providers/patterns_providers.dart';
import '../../theme/app_colors.dart';

class RecognitionResultPage extends ConsumerStatefulWidget {
  const RecognitionResultPage({super.key});

  @override
  ConsumerState<RecognitionResultPage> createState() => _RecognitionResultPageState();
}

class _RecognitionResultPageState extends ConsumerState<RecognitionResultPage> {
  RecognitionResult? _result;
  bool _isLoading = false;
  String? _error;
  Map<int, int>? _inventoryMap;
  bool _isDeducting = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final path = GoRouterState.of(context).extra as String?;
    if (path != null && _result == null && !_isLoading) {
      _startRecognition(path);
    }
  }

  Future<void> _startRecognition(String imagePath) async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // 构建标准色列表
      final state = ref.read(inventoryStateProvider);
      final standards = state.items.map((i) => StandardColor(
        colorId: i.colorId,
        colorName: i.colorName,
        hexValue: i.hexValue,
        r: i.r, g: i.g, b: i.b,
      )).toList();

      final matcher = ColorMatcher(standards);
      final service = PatternRecognitionService(matcher);
      final result = await service.recognize(imagePath);

      // 构建库存映射
      final invMap = <int, int>{};
      for (final item in state.items) {
        invMap[item.colorId] = item.currentQty;
      }

      setState(() {
        _result = result;
        _inventoryMap = invMap;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('识别结果'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.pop(),
        ),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('正在识别图纸中的色号...'),
          ],
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text('识别失败: $_error'),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () => context.pop(),
              child: const Text('返回重试'),
            ),
          ],
        ),
      );
    }

    if (_result == null) {
      return const Center(child: Text('请上传图纸'));
    }

    final result = _result!;
    final totalColors = result.colorConsumptions.length;
    final totalBeads = result.colorConsumptions.values.fold<int>(0, (a, b) => a + b);

    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // 图纸缩略图
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(
                  File(result.imagePath),
                  height: 200,
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: 16),

              // 统计信息
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _StatItem('色号数', '$totalColors'),
                      _StatItem('总颗数', '$totalBeads'),
                      _StatItem('尺寸', '${result.width}×${result.height}'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // 色号消耗清单
              const Text(
                '色号消耗清单',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),

              ...result.colorConsumptions.entries.map((entry) {
                final colorId = entry.key;
                final needed = entry.value;
                final available = _inventoryMap?[colorId] ?? 0;
                final sufficient = available >= needed;

                return Card(
                  color: sufficient ? null : Colors.red.shade50,
                  child: ListTile(
                    dense: true,
                    leading: Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: Color.fromARGB(
                          255,
                          _getR(colorId),
                          _getG(colorId),
                          _getB(colorId),
                        ),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                    ),
                    title: Text('#${colorId.toString().padLeft(3, '0')}'),
                    subtitle: Text('需要 ${needed} 颗'),
                    trailing: Text(
                      sufficient
                          ? '库存 $available ✓'
                          : '库存 $available ✗ (缺 ${needed - available})',
                      style: TextStyle(
                        color: sufficient ? AppColors.success : AppColors.warning,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                );
              }),
            ],
          ),
        ),

        // 底部操作按钮
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _isDeducting ? null : _handleDeduct,
                icon: _isDeducting
                    ? const SizedBox(
                        width: 16, height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.check_circle),
                label: Text(_isDeducting ? '扣除中...' : '确认扣除库存'),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  backgroundColor: AppColors.primary,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _handleDeduct() async {
    setState(() => _isDeducting = true);

    try {
      final result = _result!;
      final inventoryNotifier = ref.read(inventoryStateProvider.notifier);
      final patternsNotifier = ref.read(patternsStateProvider.notifier);

      // 检查库存
      final insufficient = <MapEntry<int, int>>[];
      for (final entry in result.colorConsumptions.entries) {
        final available = _inventoryMap?[entry.key] ?? 0;
        if (available < entry.value) {
          insufficient.add(MapEntry(entry.key, entry.value));
        }
      }

      if (insufficient.isNotEmpty) {
        // 库存不足
        if (!mounted) return;
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('库存不足'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('以下色号库存不足，已取消扣除操作：'),
                const SizedBox(height: 8),
                ...insufficient.map((e) => Text(
                  '#${e.key.toString().padLeft(3, '0')}: 需要 ${e.value} 颗，'
                  '仅有 ${_inventoryMap?[e.key] ?? 0} 颗',
                )),
              ],
            ),
            actions: [
              FilledButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('知道了'),
              ),
            ],
          ),
        );
        setState(() => _isDeducting = false);
        return;
      }

      // 库存充足 — 执行扣除
      for (final entry in result.colorConsumptions.entries) {
        await inventoryNotifier.consume(entry.key, entry.value);
      }

      // 保存图纸记录
      final patternId = const Uuid().v4();
      await patternsNotifier.savePattern(
        pattern: PatternItem(
          id: patternId,
          title: '图纸_${DateTime.now().toString().substring(0, 19).replaceAll(':', '').replaceAll(' ', '_')}',
          originalImage: result.imagePath,
          uploadTime: DateTime.now(),
          status: 'pending',
          source: 'ai_recognize',
          createdAt: DateTime.now(),
        ),
        consumptions: result.colorConsumptions.entries.map((e) => PatternConsumptionItem(
          id: 0,
          patternId: patternId,
          colorId: e.key,
          quantity: e.value,
        )).toList(),
      );

      // 检查是否有色号低于500
      final lowStock = await ref.read(inventoryServiceProvider).getLowStockColors();

      if (!mounted) return;
      if (lowStock.isNotEmpty) {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('库存提示'),
            content: Text('扣除后，有 ${lowStock.length} 种色号库存不足 500 颗，请注意补货。'),
            actions: [
              FilledButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  context.go('/inventory');
                },
                child: const Text('查看库存'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  context.go('/home');
                },
                child: const Text('返回首页'),
              ),
            ],
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('库存扣除成功！'), backgroundColor: AppColors.success),
        );
        context.go('/patterns');
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('操作失败: $e'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _isDeducting = false);
    }
  }

  int _getR(int colorId) {
    final state = ref.read(inventoryStateProvider);
    final item = state.items.where((i) => i.colorId == colorId).firstOrNull;
    return item?.r ?? 128;
  }

  int _getG(int colorId) {
    final state = ref.read(inventoryStateProvider);
    final item = state.items.where((i) => i.colorId == colorId).firstOrNull;
    return item?.g ?? 128;
  }

  int _getB(int colorId) {
    final state = ref.read(inventoryStateProvider);
    final item = state.items.where((i) => i.colorId == colorId).firstOrNull;
    return item?.b ?? 128;
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  const _StatItem(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }
}
