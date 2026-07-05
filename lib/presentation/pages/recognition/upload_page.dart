import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/services/ocr_service.dart';

class UploadPage extends ConsumerStatefulWidget {
  const UploadPage({super.key});

  @override
  ConsumerState<UploadPage> createState() => _UploadPageState();
}

class _UploadPageState extends ConsumerState<UploadPage> {
  String? _imagePath;
  GridDetectionResult? _grid;
  bool _detecting = false;
  int _gridCols = 52;
  int _gridRows = 52;
  bool _customGrid = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('上传图纸'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.pop(),
        ),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_imagePath == null) {
      return _buildPicker();
    }
    if (_detecting) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('正在检测网格区域...'),
          ],
        ),
      );
    }
    if (_grid == null) {
      return _buildPicker(error: '未检测到网格区域，请确认图纸清晰完整');
    }
    return _buildGridSizePicker();
  }

  Widget _buildPicker({String? error}) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (error != null) ...[
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(error!, textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.red, fontSize: 15)),
            const SizedBox(height: 24),
          ],
          const Icon(Icons.upload_file, size: 80, color: Colors.grey),
          const SizedBox(height: 16),
          const Text('上传拼豆图纸',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text('支持 JPG/PNG 格式\n建议分辨率不低于 1024×1024',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600])),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FilledButton.icon(
                onPressed: () => _pickImage(ImageSource.camera),
                icon: const Icon(Icons.camera_alt),
                label: const Text('拍照'),
              ),
              const SizedBox(width: 16),
              FilledButton.icon(
                onPressed: () => _pickImage(ImageSource.gallery),
                icon: const Icon(Icons.photo_library),
                label: const Text('从相册选择'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGridSizePicker() {
    const presets = [52, 78, 104];
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.check_circle, size: 64, color: Colors.green),
            const SizedBox(height: 16),
            const Text('已检测到网格区域', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('网格区域: ${_grid!.cropW}×${_grid!.cropH}',
                style: TextStyle(color: Colors.grey[600])),
            const SizedBox(height: 24),
            const Text('选择网格尺寸', style: TextStyle(fontWeight: FontWeight.bold)),
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
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('列:'),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 72,
                    child: TextField(
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
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
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (v) => _gridRows = int.tryParse(v) ?? 52,
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 24),
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
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: source, maxWidth: 1920);
    if (image == null) return;

    setState(() {
      _imagePath = image.path;
      _detecting = true;
      _grid = null;
    });

    final service = OcrService();
    final grid = await service.detectGrid(image.path);

    if (!mounted) return;
    setState(() {
      _detecting = false;
      _grid = grid;
    });
  }

  void _handleNext() {
    if (_imagePath == null || _grid == null) return;
    context.push('/recognition/result', extra: {
      'imagePath': _imagePath,
      'cropX': _grid!.cropX,
      'cropY': _grid!.cropY,
      'cropW': _grid!.cropW,
      'cropH': _grid!.cropH,
      'gridCols': _gridCols,
      'gridRows': _gridRows,
    });
  }
}
