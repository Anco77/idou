import 'dart:math';
import 'package:image/image.dart' as img;

class GridDetectionResult {
  final int cropX, cropY, cropW, cropH;

  const GridDetectionResult({
    required this.cropX,
    required this.cropY,
    required this.cropW,
    required this.cropH,
  });
}

class GridDetector {
  /// Find the grid area in the image.
  /// Returns the bounding box of the high-variance (cell) region.
  /// Does NOT detect individual grid lines — caller provides grid dimensions.
  static GridDetectionResult? detect(img.Image image) {
    const sampleStep = 3;

    List<int> findBounds(int axis) {
      final len = axis == 0 ? image.width : image.height;
      final other = axis == 0 ? image.height : image.width;

      // Compute variance profile
      final varProfile = <double>[];
      for (int i = 0; i < other; i++) {
        double sumR = 0, sumG = 0, sumB = 0;
        int n = 0;
        for (int j = 0; j < len; j += sampleStep) {
          final px = axis == 0 ? image.getPixel(j, i) : image.getPixel(i, j);
          sumR += px.r; sumG += px.g; sumB += px.b; n++;
        }
        if (n == 0) { varProfile.add(0); continue; }
        final aR = sumR / n, aG = sumG / n, aB = sumB / n;
        double va = 0; int vn = 0;
        for (int j = 0; j < len; j += sampleStep) {
          final px = axis == 0 ? image.getPixel(j, i) : image.getPixel(i, j);
          va += (px.r - aR) * (px.r - aR) +
              (px.g - aG) * (px.g - aG) +
              (px.b - aB) * (px.b - aB);
          vn++;
        }
        varProfile.add(vn > 0 ? sqrt(va / vn) : 0);
      }

      // Smooth
      final smooth = List<double>.generate(varProfile.length, (i) {
        double s = 0; int c = 0;
        for (int k = max(0, i - 2); k <= min(varProfile.length - 1, i + 2); k++) {
          s += varProfile[k]; c++;
        }
        return s / c;
      });

      if (smooth.isEmpty) return [];

      // Find peak variance → center of grid
      final peakVal = smooth.reduce(max);
      if (peakVal < 10) return [];
      final peakIdx = smooth.indexOf(peakVal);

      // Find boundaries: expand until variance drops below threshold
      const thresholdRatio = 0.25;
      final threshold = peakVal * thresholdRatio;

      int top = peakIdx;
      while (top > 0 && smooth[top] > threshold) top--;
      int bottom = peakIdx;
      while (bottom < smooth.length - 1 && smooth[bottom] > threshold) bottom++;

      // Add margin
      const margin = 5;
      return [
        max(0, top - margin),
        min(smooth.length - 1, bottom + margin),
      ];
    }

    final hBounds = findBounds(0);
    final vBounds = findBounds(1);
    if (hBounds.length < 2 || vBounds.length < 2) return null;

    final cropY = hBounds[0];
    final cropH = hBounds[1] - hBounds[0];
    final cropX = vBounds[0];
    final cropW = vBounds[1] - vBounds[0];

    if (cropW < 50 || cropH < 50) return null;

    return GridDetectionResult(
      cropX: cropX, cropY: cropY,
      cropW: cropW, cropH: cropH,
    );
  }
}
