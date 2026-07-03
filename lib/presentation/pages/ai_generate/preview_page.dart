import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image/image.dart' as img;
import 'package:uuid/uuid.dart';
import '../../../core/database/daos/patterns_dao.dart';
import '../../../core/utils/color_matcher.dart';
import '../../../domain/services/pattern_generation_service.dart';
import '../../providers/inventory_providers.dart';
import '../../providers/patterns_providers.dart';
import '../../theme/app_colors.dart';

class PreviewPage extends ConsumerStatefulWidget {
  const PreviewPage({super.key});

  @override
  ConsumerState<PreviewPage> createState() => _PreviewPageState();
}

class _PreviewPageState extends ConsumerState<PreviewPage> {
  GenerationResult? _result;
  bool _isLoading = false;
  String? _error;
  BoardType? _boardType;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final extra = GoRouterState.of(context).extra as Map<String, dynamic>?;
    if (extra != null && _result == null && !_isLoading) {
      _startGeneration(extra);
    }
  }

  Future<void> _startGeneration(Map<String, dynamic> extra) async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final imagePath = extra['imagePath'] as String;
      final boardName = extra['boardType'] as String;
      final cropData = extra['cropRect'] as CropRect;

      _boardType = BoardType.values.firstWhere((t) => t.name == boardName);

      // 构建标准色列表
      final state = ref.read(inventoryStateProvider);
      final standards = state.items.map((i) => StandardColor(
        colorId: i.colorId,
        colorName: i.colorName,
        hexValue: i.hexValue,
        r: i.r, g: i.g, b: i.b,
      )).toList();

      final matcher = ColorMatcher(standards);
      final service = PatternGenerationService(matcher);
      final result = await service.generate(
        imagePath: imagePath,
        cropRect: cropData,
        boardType: _boardType!,
      );

      setState(() {
        _result = result;
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
        title: Text('生成预览 ${_boardType != null ? "(${_boardType!.label})" : ""}'),
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
            Text('正在生成图纸...'),
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
            Text('生成失败: $_error'),
            FilledButton(onPressed: () => context.pop(), child: const Text('返回')),
          ],
        ),
      );
    }

    if (_result == null) {
      return const Center(child: Text('请先上传照片'));
    }

    final result = _result!;
    final sortedMaterials = result.materialList.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // 预览图
              Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.memory(
                    img.encodePng(result.previewImage),
                    height: 300,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // 统计
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _Stat('板型', result.boardType.label),
                      _Stat('尺寸', '${result.boardType.size}×${result.boardType.size}'),
                      _Stat('总颗数', '${result.totalBeads}'),
                      _Stat('色号数', '${result.materialList.length}'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // 用料清单
              const Text('所需材料清单',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),

              ...sortedMaterials.map((entry) {
                final colorId = entry.key;
                final count = entry.value;

                return ListTile(
                  dense: true,
                  leading: Container(
                    width: 24, height: 24,
                    decoration: BoxDecoration(
                      color: _getColor(colorId),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                  ),
                  title: Text('#${colorId.toString().padLeft(3, '0')}'),
                  trailing: Text('${count} 颗',
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                );
              }),
            ],
          ),
        ),

        // 底部操作
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _saveToPatterns(result),
                    icon: const Icon(Icons.save_outlined),
                    label: const Text('保存为图纸'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () => _deductAndSave(result),
                    icon: const Icon(Icons.check_circle),
                    label: const Text('扣库存并保存'),
                    style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Color _getColor(int colorId) {
    final state = ref.read(inventoryStateProvider);
    final item = state.items.where((i) => i.colorId == colorId).firstOrNull;
    if (item == null) return Colors.grey;
    return Color.fromARGB(255, item.r, item.g, item.b);
  }

  Future<void> _saveToPatterns(GenerationResult result) async {
    final id = const Uuid().v4();
    final notifier = ref.read(patternsStateProvider.notifier);
    final imagePath = result.sourceImagePath;

    await notifier.savePattern(
      pattern: PatternItem(
        id: id,
        title: 'AI图纸_${DateTime.now().toString().substring(0, 19).replaceAll(':', '').replaceAll(' ', '_')}',
        originalImage: imagePath,
        uploadTime: DateTime.now(),
        status: 'pending',
        source: 'ai_generate',
        createdAt: DateTime.now(),
      ),
      consumptions: result.materialList.entries.map((e) => PatternConsumptionItem(
        id: 0,
        patternId: id,
        colorId: e.key,
        quantity: e.value,
      )).toList(),
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('图纸已保存！')),
      );
      context.go('/patterns');
    }
  }

  Future<void> _deductAndSave(GenerationResult result) async {
    // 先保存
    await _saveToPatterns(result);

    // 再扣库存
    final notifier = ref.read(inventoryStateProvider.notifier);
    for (final entry in result.materialList.entries) {
      await notifier.consume(entry.key, entry.value);
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('库存已扣除！'), backgroundColor: AppColors.success),
      );
    }
  }
}

class _Stat extends StatelessWidget {
  final String label;
  final String value;
  const _Stat(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
      ],
    );
  }
}
