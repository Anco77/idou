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
  final GlobalKey _ivKey = GlobalKey();

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

  @override
  void dispose() {
    _transformController.dispose();
    _colsController.dispose();
    _rowsController.dispose();
    super.dispose();
  }

  Rect _computeCropRectInImage(Size ivSize) {
    final cropW = ivSize.width * 0.85;
    final cropH = ivSize.height * 0.7;
    final cropLeft = (ivSize.width - cropW) / 2;
    final cropTop = (ivSize.height - cropH) / 2;
    final cropRectScreen = Rect.fromLTWH(cropLeft, cropTop, cropW, cropH);

    final matrix = _transformController.value;
    final inverse = Matrix4.inverted(matrix);

    final tl = MatrixUtils.transformPoint(inverse, cropRectScreen.topLeft);
    final br = MatrixUtils.transformPoint(inverse, cropRectScreen.bottomRight);
    final cropInChild = Rect.fromLTRB(tl.dx, tl.dy, br.dx, br.dy);

    // Image fills the SizedBox 1:1 (BoxFit.fill), so child coords = image coords
    // But we need to scale from display size to pixel size
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
    final screenH = MediaQuery.of(context).size.height - 300;
    final scale = min(screenW / _imageSize!.width, screenH / _imageSize!.height);
    return Size(_imageSize!.width * scale, _imageSize!.height * scale);
  }

  void _handleNext() {
    final ivRenderBox = _ivKey.currentContext?.findRenderObject() as RenderBox?;
    if (ivRenderBox == null || _imagePath == null) return;

    final cropRect = _computeCropRectInImage(ivRenderBox.size);

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
          : LayoutBuilder(
              builder: (context, constraints) {
                final displaySize = _displaySize();
                return Column(
                  children: [
                    Expanded(
                      child: Stack(
                        key: _ivKey,
                        children: [
                          InteractiveViewer(
                            transformationController: _transformController,
                            constrained: false,
                            child: SizedBox(
                              width: displaySize.width,
                              height: displaySize.height,
                              child: Image.file(
                                File(_imagePath!),
                                fit: BoxFit.fill,
                              ),
                            ),
                          ),
                          // Semi-transparent overlay with crop frame cutout
                          ..._buildOverlay(constraints),
                          // Crop frame border
                          Center(
                            child: SizedBox(
                              width: constraints.maxWidth * 0.85,
                              height: constraints.maxHeight * 0.7,
                              child: IgnorePointer(
                                child: Container(
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.white, width: 2),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    _buildBottomBar(),
                  ],
                );
              },
            ),
    );
  }

  List<Widget> _buildOverlay(BoxConstraints constraints) {
    final cropW = constraints.maxWidth * 0.85;
    final cropH = constraints.maxHeight * 0.7;
    final cropLeft = (constraints.maxWidth - cropW) / 2;
    final cropTop = (constraints.maxHeight - cropH) / 2;
    return [
      // Top
      Positioned(top: 0, left: 0, right: 0, height: cropTop,
        child: Container(color: Colors.black54)),
      // Bottom
      Positioned(top: cropTop + cropH, left: 0, right: 0, bottom: 0,
        child: Container(color: Colors.black54)),
      // Left
      Positioned(top: cropTop, left: 0, width: cropLeft, height: cropH,
        child: Container(color: Colors.black54)),
      // Right
      Positioned(top: cropTop, left: cropLeft + cropW, right: 0, height: cropH,
        child: Container(color: Colors.black54)),
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
