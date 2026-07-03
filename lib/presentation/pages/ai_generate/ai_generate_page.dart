import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

class AiGeneratePage extends StatelessWidget {
  const AiGeneratePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI生成图纸'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.auto_awesome, size: 80, color: Colors.amber),
            const SizedBox(height: 16),
            const Text(
              '照片转拼豆图纸',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              '上传一张照片，AI将识别主要部分\n并转换为拼豆图纸',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            // 板型说明
            Card(
              margin: const EdgeInsets.symmetric(horizontal: 32, vertical: 8),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('可选板型', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    _BoardInfo('小板', '52 × 52', '2,704 颗'),
                    _BoardInfo('中板', '78 × 78', '6,084 颗'),
                    _BoardInfo('大板', '104 × 104', '10,816 颗'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
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

    // 跳转到裁剪页面
    context.push('/ai-generate/crop', extra: image.path);
  }
}

class _BoardInfo extends StatelessWidget {
  final String name;
  final String size;
  final String beads;
  const _BoardInfo(this.name, this.size, this.beads);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          SizedBox(width: 48, child: Text(name, style: const TextStyle(fontSize: 13))),
          Text(size, style: const TextStyle(fontSize: 13)),
          const Spacer(),
          Text(beads, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
