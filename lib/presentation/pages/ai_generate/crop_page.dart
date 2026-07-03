import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../domain/services/pattern_generation_service.dart';

class CropPage extends StatefulWidget {
  const CropPage({super.key});

  @override
  State<CropPage> createState() => _CropPageState();
}

class _CropPageState extends State<CropPage> {
  String? _imagePath;
  BoardType? _selectedBoard;
  final _boardTypes = BoardType.values;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final path = GoRouterState.of(context).extra as String?;
    if (path != null && _imagePath == null) {
      setState(() => _imagePath = path);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('裁剪主体'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.pop(),
        ),
      ),
      body: _imagePath == null
          ? const Center(child: Text('未选择图片'))
          : Column(
              children: [
                Expanded(
                  child: Center(
                    child: InteractiveViewer(
                      minScale: 0.5,
                      maxScale: 3.0,
                      child: Stack(
                        children: [
                          Image.file(
                            File(_imagePath!),
                            fit: BoxFit.contain,
                          ),
                          // 裁剪框（示意）
                          Center(
                            child: Container(
                              width: 200,
                              height: 200,
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.amber, width: 2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Center(
                                child: Text(
                                  '请手动框选主体区域\n（后续版本可拖拽调整）',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.amber,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    shadows: [Shadow(color: Colors.black54, blurRadius: 4)],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                // 板型选择
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      const Text('选择板型', style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: _boardTypes.map((type) {
                          final selected = _selectedBoard == type;
                          return GestureDetector(
                            onTap: () => setState(() => _selectedBoard = type),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              decoration: BoxDecoration(
                                color: selected
                                    ? Theme.of(context).colorScheme.primaryContainer
                                    : Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: selected
                                      ? Theme.of(context).colorScheme.primary
                                      : Colors.grey.shade300,
                                  width: selected ? 2 : 1,
                                ),
                              ),
                              child: Column(
                                children: [
                                  Text(type.label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                  Text('${type.size}×${type.size}', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          onPressed: _selectedBoard == null
                              ? null
                              : () {
                                  // 使用全图作为裁剪区域（简化版）
                                  context.push('/ai-generate/preview', extra: {
                                    'imagePath': _imagePath,
                                    'boardType': _selectedBoard!.name,
                                    'cropRect': CropRect(x: 0, y: 0, width: 400, height: 400),
                                  });
                                },
                          icon: const Icon(Icons.auto_awesome),
                          label: Text('生成图纸 (${_selectedBoard?.label ?? "请选择板型"})'),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
