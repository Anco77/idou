import 'dart:io';
import 'dart:typed_data';
import 'package:image/image.dart' as img;
import '../utils/color_matcher.dart';

class PatternRecognitionResult {
  final String imagePath;
  final int gridCols;
  final int gridRows;
  final List<List<StandardColor?>> grid;
  final Map<int, int> colorConsumptions;

  const PatternRecognitionResult({
    required this.imagePath,
    required this.gridCols,
    required this.gridRows,
    required this.grid,
    required this.colorConsumptions,
  });
}

class BeadPatternService {
  final ColorMatcher _colorMatcher;

  BeadPatternService(this._colorMatcher);

  Future<PatternRecognitionResult> process({
    required String imagePath,
    required int cropX,
    required int cropY,
    required int cropW,
    required int cropH,
    required int gridCols,
    required int gridRows,
  }) async {
    final bytes = await File(imagePath).readAsBytes();
    final image = img.decodeImage(bytes);
    if (image == null) throw Exception('无法解码图像');

    final cropped = img.copyCrop(image, x: cropX, y: cropY, width: cropW, height: cropH);
    final processed = _preprocess(cropped);
    final rawPixels = processed.getBytes(order: img.ChannelOrder.rgba);
    final pixels = Uint8List.fromList(rawPixels);
    final w = processed.width;
    final h = processed.height;

    final cellW = w / gridCols;
    final cellH = h / gridRows;

    final grid = List<List<StandardColor?>>.generate(
      gridRows, (_) => List<StandardColor?>.filled(gridCols, null),
    );
    final colorCounts = <int, int>{};

    for (int row = 0; row < gridRows; row++) {
      for (int col = 0; col < gridCols; col++) {
        final x0 = (col * cellW).round();
        final y0 = (row * cellH).round();
        final x1 = ((col + 1) * cellW).round();
        final y1 = ((row + 1) * cellH).round();

        final rgbs = _samplePixels(pixels, w, h, x0, y0, x1 - x0, y1 - y0);
        if (rgbs.isEmpty) continue;

        final color = _colorMatcher.gridMatchDominant(rgbs);
        grid[row][col] = color;
        colorCounts[color.colorId] = (colorCounts[color.colorId] ?? 0) + 1;
      }
    }

    final filtered = Map<int, int>.fromEntries(
      colorCounts.entries.where((e) => e.value > 2),
    );

    return PatternRecognitionResult(
      imagePath: imagePath,
      gridCols: gridCols,
      gridRows: gridRows,
      grid: grid,
      colorConsumptions: filtered,
    );
  }

  List<List<int>> _samplePixels(Uint8List pixels, int w, int h, int x, int y, int cellW, int cellH) {
    final result = <List<int>>[];
    const step = 2;
    for (int py = y; py < y + cellH && py < h; py += step) {
      for (int px = x; px < x + cellW && px < w; px += step) {
        final idx = (py * w + px) * 4;
        if (idx + 3 >= pixels.length) continue;
        if (pixels[idx + 3] < 128) continue;
        result.add([pixels[idx], pixels[idx + 1], pixels[idx + 2]]);
      }
    }
    return result;
  }

  img.Image _preprocess(img.Image image) {
    const maxSize = 1200;
    if (image.width > maxSize || image.height > maxSize) {
      final scale = maxSize / (image.width > image.height ? image.width : image.height);
      return img.copyResize(
        image,
        width: (image.width * scale).round(),
        height: (image.height * scale).round(),
      );
    }
    return image;
  }
}
