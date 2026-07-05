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
    const varianceThreshold = 50.0;
    const minLines = 8;
    const spacingTolerance = 0.30;
    const mergeDist = 3;
    const sampleStep = 2;

    List<int> findLines(int axis) {
      final w = image.width;
      final h = image.height;
      final len = axis == 0 ? w : h;
      final otherLen = axis == 0 ? h : w;

      final uniformRows = <int>[];

      for (int i = 0; i < otherLen; i++) {
        double sumR = 0, sumG = 0, sumB = 0;
        int count = 0;

        for (int j = 0; j < len; j += sampleStep) {
          final px = axis == 0 ? image.getPixel(j, i) : image.getPixel(i, j);
          sumR += px.r;
          sumG += px.g;
          sumB += px.b;
          count++;
        }

        if (count == 0) continue;

        final avgR = sumR / count;
        final avgG = sumG / count;
        final avgB = sumB / count;

        double varAcc = 0;
        int varCount = 0;
        for (int j = 0; j < len; j += sampleStep) {
          final px = axis == 0 ? image.getPixel(j, i) : image.getPixel(i, j);
          varAcc += (px.r - avgR) * (px.r - avgR) +
              (px.g - avgG) * (px.g - avgG) +
              (px.b - avgB) * (px.b - avgB);
          varCount++;
        }

        if (varCount == 0) continue;
        final variance = sqrt(varAcc / varCount);

        if (variance < varianceThreshold) {
          uniformRows.add(i);
        }
      }

      if (uniformRows.length < minLines) return [];

      final merged = <int>[uniformRows[0]];
      for (int i = 1; i < uniformRows.length; i++) {
        if (uniformRows[i] - merged.last > mergeDist) {
          merged.add(uniformRows[i]);
        }
      }
      if (merged.length < minLines) return [];

      final gaps = <int>[];
      for (int i = 1; i < merged.length; i++) {
        gaps.add(merged[i] - merged[i - 1]);
      }

      int bestStart = 0, bestLen = 0;
      for (int s = 0; s < gaps.length; s++) {
        int sumG = 0;
        for (int e = s; e < gaps.length; e++) {
          sumG += gaps[e];
          final count = e - s + 1;
          if (count < minLines - 1) continue;
          final avg = sumG / count;
          bool consistent = true;
          for (int k = s; k <= e; k++) {
            if ((gaps[k] - avg).abs() > (avg * spacingTolerance).round()) {
              consistent = false;
              break;
            }
          }
          if (consistent && count > bestLen) {
            bestLen = count;
            bestStart = s;
          }
        }
      }

      if (bestLen < minLines - 1) return [];

      final result = <int>[merged[bestStart]];
      for (int k = 1; k <= bestLen; k++) {
        result.add(merged[bestStart + k]);
      }
      return result;
    }

    final hLines = findLines(0);
    final vLines = findLines(1);

    if (hLines.length < minLines || vLines.length < minLines) {
      return null;
    }

    final cropX = vLines.first;
    final cropY = hLines.first;
    final cropW = vLines.last - vLines.first;
    final cropH = hLines.last - hLines.first;
    final gridRows = hLines.length - 1;
    final gridCols = vLines.length - 1;

    if (cropW <= 0 || cropH <= 0 || gridRows < 2 || gridCols < 2) return null;

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
