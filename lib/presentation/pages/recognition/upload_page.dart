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
  String? _error;

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
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_error != null) ...[
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.red, fontSize: 15),
              ),
              const SizedBox(height: 24),
            ],
            const Icon(Icons.upload_file, size: 80, color: Colors.grey),
            const SizedBox(height: 16),
            const Text(
              '上传拼豆图纸',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              '支持 JPG/PNG 格式\n建议分辨率不低于 1024×1024',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FilledButton.icon(
                  onPressed: () => _pickImage(context, ImageSource.camera),
                  icon: const Icon(Icons.camera_alt),
                  label: const Text('拍照'),
                ),
                const SizedBox(width: 16),
                FilledButton.icon(
                  onPressed: () => _pickImage(context, ImageSource.gallery),
                  icon: const Icon(Icons.photo_library),
                  label: const Text('从相册选择'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage(BuildContext context, ImageSource source) async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: source, maxWidth: 1920);
    if (image == null) return;

    setState(() => _error = null);

    final service = OcrService();
    final grid = await service.detectGrid(image.path);

    if (grid != null) {
      context.push('/recognition/result', extra: {
        'imagePath': image.path,
        'cropX': grid.cropX,
        'cropY': grid.cropY,
        'cropW': grid.cropW,
        'cropH': grid.cropH,
        'gridCols': grid.gridCols,
        'gridRows': grid.gridRows,
      });
    } else {
      setState(() {
        _error = '未检测到网格，请确认图纸清晰完整\n建议使用截图而非拍照';
      });
    }
  }
}
