import 'package:image/image.dart' as img;

class GridDetectionResult {
  final int cropX, cropY, cropW, cropH;
  final int gridCols, gridRows;

  const GridDetectionResult({
    required this.cropX,
    required this.cropY,
    required this.cropW,
    required this.cropH,
    required this.gridCols,
    required this.gridRows,
  });
}

class GridDetector {
  static GridDetectionResult? detect(img.Image image) {
    const brightnessThreshold = 180;
    const whiteRatio = 0.85;
    const minGridLines = 10;
    const spacingTolerance = 0.10;

    final w = image.width;
    final h = image.height;

    List<int> findLines(int axis) {
      final lines = <int>[];
      final len = axis == 0 ? w : h;
      final otherLen = axis == 0 ? h : w;

      for (int i = 0; i < otherLen; i++) {
        int whiteCount = 0;
        for (int j = 0; j < len; j++) {
          final px = axis == 0
              ? image.getPixel(j, i)
              : image.getPixel(i, j);
          if (px.r.toInt() > brightnessThreshold &&
              px.g.toInt() > brightnessThreshold &&
              px.b.toInt() > brightnessThreshold) {
            whiteCount++;
          }
        }
        if (whiteCount >= len * whiteRatio) {
          lines.add(i);
        }
      }

      if (lines.isEmpty) return [];

      final merged = <int>[lines[0]];
      for (int i = 1; i < lines.length; i++) {
        if (lines[i] - merged.last > 2) {
          merged.add(lines[i]);
        }
      }
      return merged;
    }

    final hLines = findLines(0);
    final vLines = findLines(1);

    if (hLines.length < minGridLines || vLines.length < minGridLines) {
      return null;
    }

    final hSpacings = <int>[];
    for (int i = 1; i < hLines.length; i++) {
      hSpacings.add(hLines[i] - hLines[i - 1]);
    }
    final vSpacings = <int>[];
    for (int i = 1; i < vLines.length; i++) {
      vSpacings.add(vLines[i] - vLines[i - 1]);
    }

    if (hSpacings.isEmpty || vSpacings.isEmpty) return null;

    final avgH = hSpacings.reduce((a, b) => a + b) ~/ hSpacings.length;
    final avgV = vSpacings.reduce((a, b) => a + b) ~/ vSpacings.length;

    final hConsistent = hSpacings.every((s) =>
        (s - avgH).abs() <= (avgH * spacingTolerance).round());
    final vConsistent = vSpacings.every((s) =>
        (s - avgV).abs() <= (avgV * spacingTolerance).round());

    if (!hConsistent || !vConsistent) {
      return null;
    }

    final gridRows = hLines.length - 1;
    final gridCols = vLines.length - 1;

    if (gridRows < 2 || gridCols < 2) return null;

    final cropX = vLines.first;
    final cropY = hLines.first;
    final cropW = vLines.last - vLines.first;
    final cropH = hLines.last - hLines.first;

    if (cropW <= 0 || cropH <= 0) return null;

    return GridDetectionResult(
      cropX: cropX,
      cropY: cropY,
      cropW: cropW,
      cropH: cropH,
      gridCols: gridCols,
      gridRows: gridRows,
    );
  }
}
