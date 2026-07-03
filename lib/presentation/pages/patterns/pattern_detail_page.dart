import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/database/daos/patterns_dao.dart';
import '../../../domain/repositories/patterns_repository.dart';
import '../../providers/patterns_providers.dart';
import '../../theme/app_colors.dart';

class PatternDetailPage extends ConsumerStatefulWidget {
  final String patternId;
  const PatternDetailPage({super.key, required this.patternId});

  @override
  ConsumerState<PatternDetailPage> createState() => _PatternDetailPageState();
}

class _PatternDetailPageState extends ConsumerState<PatternDetailPage> {
  PatternItem? _pattern;
  List<ConsumptionWithColor>? _consumptions;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final repo = ref.read(patternsRepositoryProvider);
    final pattern = await repo.getPattern(widget.patternId);
    final consumptions = await repo.getConsumptions(widget.patternId);

    if (mounted) {
      setState(() {
        _pattern = pattern;
        _consumptions = consumptions;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('图纸详情')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_pattern == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('图纸详情')),
        body: const Center(child: Text('图纸未找到')),
      );
    }

    final pattern = _pattern!;
    final consumptions = _consumptions ?? [];

    return Scaffold(
      appBar: AppBar(
        title: Text(pattern.title, overflow: TextOverflow.ellipsis),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => _editTitle(context),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.red),
            onPressed: () => _deletePattern(context),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 图纸大图
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.file(
              File(pattern.originalImage),
              height: 250,
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(height: 16),

          // 基本信息
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('基本信息', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  _Row('名称', pattern.title),
                  _Row('来源', pattern.source == 'ai_recognize' ? 'AI识别图纸' : 'AI生成图纸'),
                  _Row('上传时间', pattern.uploadTime.toString().substring(0, 19)),
                  if (pattern.completeTime != null)
                    _Row('完成时间', pattern.completeTime.toString().substring(0, 10)),
                  _Row('状态', pattern.isCompleted ? '已完成' : '未完成'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          // 消耗清单
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('色号消耗明细', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  if (consumptions.isEmpty)
                    const Text('暂无消耗数据', style: TextStyle(color: Colors.grey))
                  else
                    ...consumptions.map((c) => ListTile(
                      dense: true,
                      leading: Container(
                        width: 24, height: 24,
                        decoration: BoxDecoration(
                          color: Color(int.parse(c.hexValue.replaceFirst('#', '0xFF'))),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                      ),
                      title: Text('#${c.colorId.toString().padLeft(3, '0')} ${c.colorName}'),
                      trailing: Text('${c.quantity} 颗',
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                    )),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          // 成品照片
          if (pattern.completePhotos != null && pattern.completePhotos!.isNotEmpty)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('成品照片', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 100,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: (jsonDecode(pattern.completePhotos!) as List)
                            .map((path) => Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.file(
                                  File(path as String),
                                  width: 100, height: 100, fit: BoxFit.cover,
                                ),
                              ),
                            ))
                            .toList(),
                      ),
                    ),
                  ],
                ),
              ),
            ),

          const SizedBox(height: 16),

          // 完成操作按钮
          if (!pattern.isCompleted)
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () => _completePattern(context),
                icon: const Icon(Icons.check_circle),
                label: const Text('标记完成'),
              ),
            ),
        ],
      ),
    );
  }

  void _editTitle(BuildContext context) {
    final controller = TextEditingController(text: _pattern?.title ?? '');
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('修改名称'),
        content: TextField(controller: controller, decoration: const InputDecoration(labelText: '图纸名称')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('取消')),
          FilledButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await ref.read(patternsRepositoryProvider).updateTitle(widget.patternId, controller.text);
              _loadData();
            },
            child: const Text('保存'),
          ),
        ],
      ),
    );
  }

  void _deletePattern(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('删除图纸'),
        content: const Text('确定要删除这张图纸吗？此操作不可撤销。'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('取消')),
          FilledButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await ref.read(patternsStateProvider.notifier).deletePattern(widget.patternId);
              if (mounted) context.pop();
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('删除'),
          ),
        ],
      ),
    );
  }

  void _completePattern(BuildContext context) async {
    DateTime? selectedDate;
    final picker = ImagePicker();

    // 选择完成时间
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: _pattern!.uploadTime,
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date == null) return;
    selectedDate = date;

    // 选择成品照片
    final photos = <String>[];
    for (int i = 0; i < 3; i++) {
      final image = await picker.pickImage(source: ImageSource.gallery);
      if (image == null) break;
      photos.add(image.path);
    }

    if (photos.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请至少上传一张成品照片')),
      );
      return;
    }

    // 保存
    await ref.read(patternsRepositoryProvider).updateCompletion(
      patternId: widget.patternId,
      completeTime: selectedDate,
      photos: photos,
    );

    _loadData();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('完成记录已保存！'), backgroundColor: AppColors.success),
      );
    }
  }
}

class _Row extends StatelessWidget {
  final String label;
  final String value;
  const _Row(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          SizedBox(width: 80, child: Text(label, style: const TextStyle(color: Colors.grey, fontSize: 13))),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 13))),
        ],
      ),
    );
  }
}
