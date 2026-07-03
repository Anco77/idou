import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

class UploadPage extends ConsumerWidget {
  const UploadPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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

    // 跳转到识别结果页（传递图片路径）
    context.push('/recognition/result', extra: image.path);
  }
}
