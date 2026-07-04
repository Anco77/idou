import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import '../../../core/database/daos/inventory_dao.dart';
import '../../../core/database/daos/patterns_dao.dart';
import '../../../core/services/bead_pattern_service.dart';
import '../../../core/utils/color_matcher.dart';
import '../../providers/inventory_providers.dart';
import '../../providers/patterns_providers.dart';
import '../../providers/settings_providers.dart';
import '../../theme/app_colors.dart';

class RecognitionResultPage extends ConsumerStatefulWidget {
  const RecognitionResultPage({super.key});

  @override
  ConsumerState<RecognitionResultPage> createState() => _RecognitionResultPageState();
}

class _RecognitionResultPageState extends ConsumerState<RecognitionResultPage> {
  String? _imagePath;
  int _cropX = 0, _cropY = 0, _cropW = 0, _cropH = 0;
  int _gridCols = 52, _gridRows = 52;
  PatternRecognitionResult? _result;
  PatternRecognitionResult? _rawResult;
  double _mergeThreshold = 0;
  bool _isLoading = false;
  String? _error;
  bool _isDeducting = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final extra = GoRouterState.of(context).extra as Map<String, dynamic>?;
    if (extra != null && _imagePath == null) {
      _imagePath = extra['imagePath'] as String;
      _cropX = extra['cropX'] as int;
      _cropY = extra['cropY'] as int;
      _cropW = extra['cropW'] as int;
      _cropH = extra['cropH'] as int;
      _gridCols = extra['gridCols'] as int;
      _gridRows = extra['gridRows'] as int;
      _startRecognition();
    }
  }

  Future<void> _startRecognition() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final state = ref.read(inventoryStateProvider);
      final standards = state.items.map((i) => StandardColor(
        colorId: i.colorId,
        colorName: i.colorName,
        hexValue: i.hexValue,
        r: i.r, g: i.g, b: i.b,
      )).toList();

      final matcher = ColorMatcher(standards);
      final service = BeadPatternService(matcher);
      final mardIdToColorId = <String, int>{};
      for (final item in state.items) {
        if (item.mardId.isNotEmpty) {
          mardIdToColorId[item.mardId.toUpperCase()] = item.colorId;
        }
      }
      final raw = await service.processWithOcr(
        imagePath: _imagePath!,
        cropX: _cropX, cropY: _cropY,
        cropW: _cropW, cropH: _cropH,
        gridCols: _gridCols, gridRows: _gridRows,
        mardIdToColorId: mardIdToColorId,
      );

      if (!mounted) return;
      setState(() {
        _rawResult = raw;
        _result = raw;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _applyMerge(double threshold) {
    if (_rawResult == null) return;
    setState(() {
      _mergeThreshold = threshold;
      if (threshold <= 0) {
        _result = _rawResult;
      } else {
        final state = ref.read(inventoryStateProvider);
        final standards = state.items.map((i) => StandardColor(
          colorId: i.colorId,
          colorName: i.colorName,
          hexValue: i.hexValue,
          r: i.r, g: i.g, b: i.b,
        )).toList();
        final matcher = ColorMatcher(standards);
        final service = BeadPatternService(matcher);
        _result = service.applyMerge(_rawResult!, threshold);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('识别结果'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            while (context.canPop()) { context.pop(); }
          },
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
    final inventoryItems = ref.read(inventoryStateProvider).items;

    final sortedEntries = result.colorConsumptions.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));

    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Grid preview
              _buildGridPreview(result),
              const SizedBox(height: 16),

              // Stats
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _StatItem('色号数', '$totalColors'),
                      _StatItem('总颗数', '$totalBeads'),
                      _StatItem('尺寸', '${result.gridCols}×${result.gridRows}'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Merge threshold slider
              Card(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: Row(
                    children: [
                      const Text('颜色合并', style: TextStyle(fontSize: 14)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Slider(
                          value: _mergeThreshold,
                          min: 0,
                          max: 30,
                          divisions: 30,
                          label: _mergeThreshold == 0
                              ? '关闭'
                              : 'ΔE ${_mergeThreshold.round()}',
                          onChanged: _applyMerge,
                        ),
                      ),
                      SizedBox(
                        width: 48,
                        child: Text(
                          _mergeThreshold == 0 ? '关闭' : '${_mergeThreshold.round()}',
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Color consumption list
              const Text(
                '色号消耗清单',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),

              ...sortedEntries.map((entry) => _buildColorRow(
                entry.key, entry.value, inventoryItems,
              )),
            ],
          ),
        ),

        // Save button
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
                label: Text(_isDeducting ? '保存中...' : '保存图纸并扣除库存'),
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

  Widget _buildGridPreview(PatternRecognitionResult result) {
    // Show a small color-coded grid representation
    const previewCellSize = 6.0;
    final previewW = result.gridCols * previewCellSize;
    final previewH = result.gridRows * previewCellSize;

    return Center(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
          ),
          child: CustomPaint(
            size: Size(previewW.clamp(50, 300), previewH.clamp(50, 300)),
            painter: _GridPreviewPainter(result.grid),
          ),
        ),
      ),
    );
  }

  Widget _buildColorRow(int colorId, int needed, List<InventoryWithColor> inventoryItems) {
    final item = inventoryItems.where((i) => i.colorId == colorId).firstOrNull;
    final available = item?.currentQty ?? 0;
    final r = item?.r ?? 128;
    final g = item?.g ?? 128;
    final b = item?.b ?? 128;
    final sufficient = available >= needed;

    return Card(
      color: sufficient ? null : Colors.red.shade50,
      child: ListTile(
        dense: true,
        leading: Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: Color.fromARGB(255, r, g, b),
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: Colors.grey.shade300),
          ),
        ),
        title: Text(item?.mardId ?? '#${colorId.toString().padLeft(3, '0')}'),
        subtitle: Text('需要 $needed 颗'),
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
  }

  Future<void> _handleDeduct() async {
    setState(() => _isDeducting = true);

    try {
      final result = _result!;
      final inventoryService = ref.read(inventoryServiceProvider);
      final patternsNotifier = ref.read(patternsStateProvider.notifier);

      final inventoryItems = ref.read(inventoryStateProvider).items;

      // Use batchDeduct for transactional deduction
      final deductResult = await inventoryService.batchDeduct(
        result.colorConsumptions,
      );

      if (!deductResult.success) {
        if (!mounted) return;
        showDialog(
          context: context,
          builder: (ctx) {
            final mardIds = deductResult.insufficientColors.map((e) {
              final item = inventoryItems.where((i) => i.colorId == e.colorId).firstOrNull;
              return item?.mardId ?? '#${e.colorId.toString().padLeft(3, '0')}';
            }).toList();
            return AlertDialog(
              title: const Text('库存不足'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('以下色号库存不足，已取消扣除操作：'),
                  const SizedBox(height: 8),
                  ...deductResult.insufficientColors.asMap().entries.map((entry) {
                    final i = entry.key;
                    final e = entry.value;
                    final mardId = mardIds[i];
                    return Text(
                      '$mardId: 需要 ${e.required} 颗，仅有 ${e.available} 颗',
                    );
                  }),
                ],
              ),
            actions: [
              FilledButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('知道了'),
              ),
            ],
          );
          },
        );
        setState(() => _isDeducting = false);
        return;
      }

      // Save pattern record
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

      // Check low stock
      final threshold = ref.read(userSettingsProvider).lowStockThreshold;
      final lowStock = await inventoryService.getLowStockColors(threshold: threshold);

      if (!mounted) return;
      if (lowStock.isNotEmpty) {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('库存提示'),
            content: Text('扣除后，有 ${lowStock.length} 种色号库存不足 $threshold 颗，请注意补货。'),
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
}

class _GridPreviewPainter extends CustomPainter {
  final List<List<StandardColor?>> grid;

  _GridPreviewPainter(this.grid);

  @override
  void paint(Canvas canvas, Size size) {
    if (grid.isEmpty || grid[0].isEmpty) return;

    final cellW = size.width / grid[0].length;
    final cellH = size.height / grid.length;

    for (int row = 0; row < grid.length; row++) {
      for (int col = 0; col < grid[row].length; col++) {
        final color = grid[row][col];
        if (color == null) continue;

        canvas.drawRect(
          Rect.fromLTWH(col * cellW, row * cellH, cellW, cellH),
          Paint()..color = Color.fromARGB(255, color.r, color.g, color.b),
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _GridPreviewPainter oldDelegate) => oldDelegate.grid != grid;
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
