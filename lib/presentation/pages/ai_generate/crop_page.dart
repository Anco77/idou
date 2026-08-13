import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image/image.dart' as img;

import '../../../domain/services/pattern_generation_service.dart';

class CropPage extends StatefulWidget {
  const CropPage({super.key});

  @override
  State<CropPage> createState() => _CropPageState();
}

class _CropPageState extends State<CropPage> {
  String? _imagePath;
  Size? _imageSize;
  BoardType _selectedBoard = BoardType.mini;
  Rect _crop = const Rect.fromLTWH(.08, .08, .84, .84);
  Offset? _lastPointer;
  bool _resizing = false;
  int _maxColors = 24;
  bool _removeLightBackground = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final path = GoRouterState.of(context).extra as String?;
    if (path != null && _imagePath == null) {
      _imagePath = path;
      _loadImageSize(path);
    }
  }

  Future<void> _loadImageSize(String path) async {
    final decoded = img.decodeImage(await File(path).readAsBytes());
    if (!mounted) return;
    if (decoded == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('无法读取这张图片')),
      );
      return;
    }
    setState(() =>
        _imageSize = Size(decoded.width.toDouble(), decoded.height.toDouble()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('裁剪与转换设置'),
        leading:
            IconButton(icon: const Icon(Icons.close), onPressed: context.pop),
      ),
      body: _imagePath == null || _imageSize == null
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: LayoutBuilder(builder: (context, constraints) {
                      final fitted = applyBoxFit(
                        BoxFit.contain,
                        _imageSize!,
                        Size(constraints.maxWidth, constraints.maxHeight),
                      ).destination;
                      return Center(
                        child: SizedBox(
                          width: fitted.width,
                          height: fitted.height,
                          child: GestureDetector(
                            onPanStart: (details) {
                              _lastPointer = details.localPosition;
                              final handle = Offset(
                                _crop.right * fitted.width,
                                _crop.bottom * fitted.height,
                              );
                              _resizing =
                                  (details.localPosition - handle).distance <
                                      42;
                            },
                            onPanUpdate: (details) {
                              final previous = _lastPointer;
                              if (previous == null) return;
                              final dx =
                                  (details.localPosition.dx - previous.dx) /
                                      fitted.width;
                              final dy =
                                  (details.localPosition.dy - previous.dy) /
                                      fitted.height;
                              setState(() {
                                if (_resizing) {
                                  final width = (_crop.width + dx)
                                      .clamp(.12, 1 - _crop.left);
                                  final height = (_crop.height + dy)
                                      .clamp(.12, 1 - _crop.top);
                                  _crop = Rect.fromLTWH(
                                      _crop.left, _crop.top, width, height);
                                } else {
                                  final left = (_crop.left + dx)
                                      .clamp(0.0, 1 - _crop.width);
                                  final top = (_crop.top + dy)
                                      .clamp(0.0, 1 - _crop.height);
                                  _crop = Rect.fromLTWH(
                                      left, top, _crop.width, _crop.height);
                                }
                                _lastPointer = details.localPosition;
                              });
                            },
                            onPanEnd: (_) => _lastPointer = null,
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                Image.file(File(_imagePath!), fit: BoxFit.fill),
                                CustomPaint(
                                    painter: _CropOverlayPainter(_crop)),
                                Positioned(
                                  left: _crop.right * fitted.width - 14,
                                  top: _crop.bottom * fitted.height - 14,
                                  child: const DecoratedBox(
                                    decoration: BoxDecoration(
                                      color: Colors.amber,
                                      shape: BoxShape.circle,
                                    ),
                                    child: SizedBox(width: 28, height: 28),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ),
                Material(
                  elevation: 8,
                  color: Theme.of(context).colorScheme.surface,
                  child: SafeArea(
                    top: false,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('拖动选区，拖右下角圆点调整大小',
                              style:
                                  TextStyle(fontSize: 12, color: Colors.grey)),
                          const SizedBox(height: 10),
                          Wrap(
                            spacing: 8,
                            children: BoardType.values
                                .map((type) => ChoiceChip(
                                      label: Text(
                                          '${type.label} ${type.size}×${type.size}'),
                                      selected: _selectedBoard == type,
                                      onSelected: (_) =>
                                          setState(() => _selectedBoard = type),
                                    ))
                                .toList(),
                          ),
                          Row(
                            children: [
                              Text('最多 $_maxColors 色',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w500)),
                              Expanded(
                                child: Slider(
                                  value: _maxColors.toDouble(),
                                  min: 4,
                                  max: 48,
                                  divisions: 11,
                                  onChanged: (value) => setState(
                                      () => _maxColors = value.round()),
                                ),
                              ),
                            ],
                          ),
                          SwitchListTile(
                            contentPadding: EdgeInsets.zero,
                            dense: true,
                            title: const Text('忽略接近纯白的背景'),
                            subtitle: const Text('适合头像、插画和透明底素材'),
                            value: _removeLightBackground,
                            onChanged: (value) =>
                                setState(() => _removeLightBackground = value),
                          ),
                          SizedBox(
                            width: double.infinity,
                            child: FilledButton.icon(
                              onPressed: _continue,
                              icon: const Icon(Icons.grid_view),
                              label: const Text('转换并进入编辑'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  void _continue() {
    final size = _imageSize!;
    context.push('/ai-generate/preview', extra: {
      'imagePath': _imagePath,
      'boardType': _selectedBoard.name,
      'cropRect': CropRect(
        x: _crop.left * size.width,
        y: _crop.top * size.height,
        width: _crop.width * size.width,
        height: _crop.height * size.height,
      ),
      'maxColors': _maxColors,
      'removeLightBackground': _removeLightBackground,
    });
  }
}

class _CropOverlayPainter extends CustomPainter {
  final Rect crop;

  const _CropOverlayPainter(this.crop);

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTRB(
      crop.left * size.width,
      crop.top * size.height,
      crop.right * size.width,
      crop.bottom * size.height,
    );
    final outside = Path()
      ..addRect(Offset.zero & size)
      ..addRect(rect)
      ..fillType = PathFillType.evenOdd;
    canvas.drawPath(outside, Paint()..color = Colors.black54);
    canvas.drawRect(
      rect,
      Paint()
        ..color = Colors.amber
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
    final thirds = Paint()
      ..color = Colors.white54
      ..strokeWidth = 1;
    for (var i = 1; i < 3; i++) {
      canvas.drawLine(
        Offset(rect.left + rect.width * i / 3, rect.top),
        Offset(rect.left + rect.width * i / 3, rect.bottom),
        thirds,
      );
      canvas.drawLine(
        Offset(rect.left, rect.top + rect.height * i / 3),
        Offset(rect.right, rect.top + rect.height * i / 3),
        thirds,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _CropOverlayPainter oldDelegate) =>
      oldDelegate.crop != crop;
}
