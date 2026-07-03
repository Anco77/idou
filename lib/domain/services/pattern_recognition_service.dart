import 'dart:io';
import 'dart:typed_data';
import 'package:image/image.dart' as img;
import '../../core/utils/color_matcher.dart';

/// 图纸识别结果
class RecognitionResult {
  final String imagePath;
  final int width;
  final int height;
  final Map<int, int> colorConsumptions; // colorId -> beads count

  const RecognitionResult({
    required this.imagePath,
    required this.width,
    required this.height,
    required this.colorConsumptions,
  });
}

/// 图纸AI识别服务
class PatternRecognitionService {
  final ColorMatcher _colorMatcher;

  PatternRecognitionService(this._colorMatcher);

  /// 识别图纸中的色号消耗
  Future<RecognitionResult> recognize(String imagePath) async {
    // 1. 加载图像
    final file = File(imagePath);
    final imageBytes = await file.readAsBytes();
    final image = img.decodeImage(imageBytes);
    if (image == null) {
      throw Exception('无法解码图像');
    }

    // 2. 图像预处理：缩放到合理大小
    final processed = _preprocess(image);

    // 3. 颜色量化
    final pixels = processed.getBytes();
    final colorCounts = _colorMatcher.quantizeImage(
      Uint8List.fromList(pixels),
      processed.width,
      processed.height,
    );

    // 4. 过滤极小量色号（≤2像素的可能是噪点）
    final filtered = Map<int, int>.fromEntries(
      colorCounts.entries.where((e) => e.value > 2),
    );

    return RecognitionResult(
      imagePath: imagePath,
      width: processed.width,
      height: processed.height,
      colorConsumptions: filtered,
    );
  }

  /// 图像预处理
  img.Image _preprocess(img.Image image) {
    // 缩放：如果图像太大，缩放到最大 800px 宽
    const maxSize = 800;
    img.Image processed = image;

    if (processed.width > maxSize || processed.height > maxSize) {
      final scale = maxSize / (processed.width > processed.height
          ? processed.width
          : processed.height);
      processed = img.copyResize(processed,
          width: (processed.width * scale).round(),
          height: (processed.height * scale).round());
    }

    // 轻微锐化增强边缘
    processed = img.gaussianBlur(processed, radius: 1);

    return processed;
  }
}
