import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image/image.dart' as img;

class CropPageForRecognition extends StatefulWidget {
  const CropPageForRecognition({super.key});

  @override
  State<CropPageForRecognition> createState() => _CropPageForRecognitionState();
}

class _CropPageForRecognitionState extends State<CropPageForRecognition> {
  String? _imagePath;
  Size? _imageSize;
  final TransformationController _transformController = TransformationController();

  double _cropX = 0, _cropY = 0, _cropW = 0, _cropH = 0;

  int _gridCols = 52;
  int _gridRows = 52;
  bool _customGrid = false;
  final TextEditingController _colsController = TextEditingController(text: '52');
  final TextEditingController _rowsController = TextEditingController(text: '52');

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
    final bytes = await File(path).readAsBytes();
    final image = img.decodeImage(bytes);
    if (image != null && mounted) {
      setState(() => _imageSize = Size(image.width.toDouble(), image.height.toDouble()));
    }
  }

  void _initCropRect(double maxW, double maxH) {
    if (_cropW > 0 && _cropH > 0) return;
    _cropW = maxW * 0.85;
    _cropH = maxH * 0.7;
    _cropX = (maxW - _cropW) / 2;
    _cropY = (maxH - _cropH) / 2;
  }

  @override
  void dispose() {
    _transformController.dispose();
    _colsController.dispose();
    _rowsController.dispose();
    super.dispose();
  }

  Rect _computeCropRectInImage(Size ivSize) {
    final cropRectScreen = Rect.fromLTWH(_cropX, _cropY, _cropW, _cropH);
    final matrix = _transformController.value;
    final inverse = Matrix4.inverted(matrix);
    final tl = MatrixUtils.transformPoint(inverse, cropRectScreen.topLeft);
    final br = MatrixUtils.transformPoint(inverse, cropRectScreen.bottomRight);
    final cropInChild = Rect.fromLTRB(tl.dx, tl.dy, br.dx, br.dy);
    final imgW = _imageSize!.width;
    final imgH = _imageSize!.height;
    final displayW = _displaySize().width;
    final displayH = _displaySize().height;
    return Rect.fromLTWH(
      (cropInChild.left / displayW * imgW).clamp(0, imgW),
      (cropInChild.top / displayH * imgH).clamp(0, imgH),
      (cropInChild.width / displayW * imgW).clamp(1, imgW),
      (cropInChild.height / displayH * imgH).clamp(1, imgH),
    );
  }

  Size _displaySize() {
    if (_imageSize == null) return const Size(400, 400);
    final screenW = MediaQuery.of(context).size.width;
    final screenH = MediaQuery.of(context).size.height - kToolbarHeight - kBottomNavigationBarHeight - 200;
    final scale = min(screenW / _imageSize!.width, screenH / _imageSize!.height);
    return Size(_imageSize!.width * scale, _imageSize!.height * scale);
  }

  void _clampCrop(double maxW, double maxH) {
    _cropX = _cropX.clamp(0, maxW - _cropW);
    _cropY = _cropY.clamp(0, maxH - _cropH);
    _cropW = _cropW.clamp(60, maxW);
    _cropH = _cropH.clamp(60, maxH);
  }

  void _handleNext() {
    if (_imagePath == null) return;
    final ivSize = Size(MediaQuery.of(context).size.width,
        MediaQuery.of(context).size.height - 300);
    final cropRect = _computeCropRectInImage(ivSize);
    context.push('/recognition/result', extra: {
      'imagePath': _imagePath,
      'cropX': cropRect.left.round(),
      'cropY': cropRect.top.round(),
      'cropW': cropRect.width.round(),
      'cropH': cropRect.height.round(),
      'gridCols': _gridCols,
      'gridRows': _gridRows,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('裁剪图纸区域'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.pop(),
        ),
      ),
      body: _imagePath == null
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final maxW = constraints.maxWidth;
                      final maxH = constraints.maxHeight;
                      _initCropRect(maxW, maxH);

                      final displaySize = _displaySize();
                      return Stack(
                        children: [
                          InteractiveViewer(
                            transformationController: _transformController,
                            constrained: false,
                            minScale: 0.1,
                            maxScale: 4.0,
                            child: SizedBox(
                              width: displaySize.width,
                              height: displaySize.height,
                              child: Image.file(
                                File(_imagePath!),
                                fit: BoxFit.fill,
                              ),
                            ),
                          ),
                          _buildOverlay(maxW, maxH),
                          _buildFrame(),
                          _buildDragHandle(),
                          ..._buildCornerHandles(maxW, maxH),
                        ],
                      );
                    },
                  ),
                ),
                _buildBottomBar(),
              ],
            ),
    );
  }

  Widget _buildOverlay(double maxW, double maxH) {
    return Stack(
      children: [
        if (_cropY > 0)
          Positioned(top: 0, left: 0, right: 0, height: _cropY,
            child: IgnorePointer(child: Container(color: Colors.black54))),
        if (_cropY + _cropH < maxH)
          Positioned(top: _cropY + _cropH, left: 0, right: 0, bottom: 0,
            child: IgnorePointer(child: Container(color: Colors.black54))),
        if (_cropX > 0)
          Positioned(top: _cropY, left: 0, width: _cropX, height: _cropH,
            child: IgnorePointer(child: Container(color: Colors.black54))),
        if (_cropX + _cropW < maxW)
          Positioned(top: _cropY, left: _cropX + _cropW, right: 0, height: _cropH,
            child: IgnorePointer(child: Container(color: Colors.black54))),
      ],
    );
  }

  Widget _buildFrame() {
    return Positioned(
      top: _cropY, left: _cropX,
      width: _cropW, height: _cropH,
      child: IgnorePointer(
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.white, width: 2),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ),
    );
  }

  Widget _buildDragHandle() {
    const handleHeight = 10.0;
    return Positioned(
      top: _cropY - handleHeight,
      left: _cropX,
      width: _cropW,
      height: handleHeight * 2,
      child: GestureDetector(
        onPanUpdate: (d) {
          setState(() {
            final maxW = MediaQuery.of(context).size.width;
            final maxH = MediaQuery.of(context).size.height - 300;
            _cropX += d.delta.dx;
            _cropY += d.delta.dy;
            _clampCrop(maxW, maxH);
          });
        },
        child: Container(
          color: Colors.transparent,
          alignment: Alignment.center,
          child: Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white70,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildCornerHandles(double maxW, double maxH) {
    const s = 20.0;
    return [
      Positioned(top: _cropY - s / 2, left: _cropX - s / 2,
        child: _ResizeHandle(onPan: (dx, dy) {
          setState(() { _cropX += dx; _cropY += dy; _cropW -= dx; _cropH -= dy; _clampCrop(maxW, maxH); });
        }),
      ),
      Positioned(top: _cropY - s / 2, left: _cropX + _cropW - s / 2,
        child: _ResizeHandle(onPan: (dx, dy) {
          setState(() { _cropY += dy; _cropW += dx; _cropH -= dy; _clampCrop(maxW, maxH); });
        }),
      ),
      Positioned(top: _cropY + _cropH - s / 2, left: _cropX - s / 2,
        child: _ResizeHandle(onPan: (dx, dy) {
          setState(() { _cropX += dx; _cropW -= dx; _cropH += dy; _clampCrop(maxW, maxH); });
        }),
      ),
      Positioned(top: _cropY + _cropH - s / 2, left: _cropX + _cropW - s / 2,
        child: _ResizeHandle(onPan: (dx, dy) {
          setState(() { _cropW += dx; _cropH += dy; _clampCrop(maxW, maxH); });
        }),
      ),
    ];
  }

  Widget _buildBottomBar() {
    const presets = [52, 78, 104];
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        border: Border(top: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('网格尺寸', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              ...presets.map((size) {
                final selected = !_customGrid && _gridCols == size;
                return ChoiceChip(
                  label: Text('$size×$size'),
                  selected: selected,
                  onSelected: (_) => setState(() {
                    _customGrid = false;
                    _gridCols = size;
                    _gridRows = size;
                  }),
                );
              }),
              ChoiceChip(
                label: const Text('自定义'),
                selected: _customGrid,
                onSelected: (_) => setState(() => _customGrid = true),
              ),
            ],
          ),
          if (_customGrid) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                const Text('列:'),
                const SizedBox(width: 8),
                SizedBox(
                  width: 72,
                  child: TextField(
                    controller: _colsController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      isDense: true, contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (v) => _gridCols = int.tryParse(v) ?? 52,
                  ),
                ),
                const SizedBox(width: 16),
                const Text('行:'),
                const SizedBox(width: 8),
                SizedBox(
                  width: 72,
                  child: TextField(
                    controller: _rowsController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      isDense: true, contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (v) => _gridRows = int.tryParse(v) ?? 52,
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: _handleNext,
              icon: const Icon(Icons.auto_awesome),
              label: const Text('识别图纸'),
              style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
            ),
          ),
        ],
      ),
    );
  }
}

class _ResizeHandle extends StatelessWidget {
  final void Function(double dx, double dy) onPan;
  const _ResizeHandle({required this.onPan});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanUpdate: (d) => onPan(d.delta.dx, d.delta.dy),
      child: Container(
        width: 20,
        height: 20,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.grey.shade400, width: 2),
        ),
      ),
    );
  }
}
