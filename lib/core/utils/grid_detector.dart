import 'dart:math';
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
    const settings = [
      (sampleStep: 1, colorThreshold: 40, whiteRatio: 0.70, mergeDist: 3, spacingTolerance: 0.20, minLines: 10),
      (sampleStep: 2, colorThreshold: 60, whiteRatio: 0.50, mergeDist: 5, spacingTolerance: 0.30, minLines: 6),
    ];

    for (final s in settings) {
      final result = _detectWithParams(image, s);
      if (result != null) return result;
    }
    return null;
  }

  static GridDetectionResult? _detectWithParams(
    img.Image image,
    ({
      int sampleStep,
      int colorThreshold,
      double whiteRatio,
      int mergeDist,
      double spacingTolerance,
      int minLines,
    }) params,
  ) {
    final w = image.width;
    final h = image.height;

    List<int> findLines(int axis) {
      final lines = <int>[];
      final len = axis == 0 ? w : h;
      final otherLen = axis == 0 ? h : w;

      for (int i = 0; i < otherLen; i++) {
        final samples = <int>[];
        for (int j = 0; j < len; j += params.sampleStep) {
          final px = axis == 0 ? image.getPixel(j, i) : image.getPixel(i, j);
          samples.add(px.r.toInt());
          samples.add(px.g.toInt());
          samples.add(px.b.toInt());
        }

        if (samples.isEmpty) continue;

        int minR = 255, maxR = 0, minG = 255, maxG = 0, minB = 255, maxB = 0;
        int brightCount = 0;
        for (int k = 0; k < samples.length; k += 3) {
          final r = samples[k], g = samples[k + 1], b = samples[k + 2];
          if (r > 180 && g > 180 && b > 180) brightCount++;
          if (r < minR) minR = r;
          if (r > maxR) maxR = r;
          if (g < minG) minG = g;
          if (g > maxG) maxG = g;
          if (b < minB) minB = b;
          if (b > maxB) maxB = b;
        }

        final dr = maxR - minR, dg = maxG - minG, db = maxB - minB;
        final maxDiff = sqrt(dr * dr + dg * dg + db * db);
        final brightRatio = brightCount / (samples.length / 3);

        if (maxDiff <= params.colorThreshold || brightRatio >= params.whiteRatio) {
          lines.add(i);
        }
      }

      if (lines.isEmpty) return [];

      final merged = <int>[lines[0]];
      for (int i = 1; i < lines.length; i++) {
        if (lines[i] - merged.last > params.mergeDist) {
          merged.add(lines[i]);
        }
      }
      return merged;
    }

    final hLines = findLines(0);
    final vLines = findLines(1);

    if (hLines.length < params.minLines || vLines.length < params.minLines) {
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

    final hConsistent = hSpacings.every(
      (s) => (s - avgH).abs() <= (avgH * params.spacingTolerance).round(),
    );
    final vConsistent = vSpacings.every(
      (s) => (s - avgV).abs() <= (avgV * params.spacingTolerance).round(),
    );

    if (!hConsistent || !vConsistent) return null;

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
