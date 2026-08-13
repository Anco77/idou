import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:idou/core/utils/grid_detector.dart';

void main() {
  test('detects a rectangular synthetic grid and its dimensions', () {
    final image = img.Image(width: 200, height: 160);
    img.fill(image, color: img.ColorRgb8(250, 250, 250));
    const xLines = [20, 60, 100, 140, 180];
    const yLines = [20, 60, 100, 140];
    for (final x in xLines) {
      for (var y = 20; y <= 140; y++) {
        image.setPixel(x, y, img.ColorRgb8(80, 80, 80));
      }
    }
    for (final y in yLines) {
      for (var x = 20; x <= 180; x++) {
        image.setPixel(x, y, img.ColorRgb8(80, 80, 80));
      }
    }

    final result = GridDetector.detect(image);

    expect(result, isNotNull);
    expect(result!.gridCols, 4);
    expect(result.gridRows, 3);
    expect(result.cropX, closeTo(20, 3));
    expect(result.cropY, closeTo(20, 3));
    expect(result.cropW, closeTo(160, 6));
    expect(result.cropH, closeTo(120, 6));
    expect(result.confidence, greaterThan(0));
  });

  test('rejects an image without repeated grid lines', () {
    final image = img.Image(width: 120, height: 100);
    img.fill(image, color: img.ColorRgb8(250, 250, 250));

    expect(GridDetector.detect(image), isNull);
    final attempt = GridDetector.detectDetailed(image);
    expect(attempt.isSuccess, isFalse);
    expect(
        attempt.failure!.reason, GridDetectionFailureReason.missingAxisLines);
  });

  test('reports structured failure for an image that is too small', () {
    final attempt =
        GridDetector.detectDetailed(img.Image(width: 12, height: 12));

    expect(attempt.isSuccess, isFalse);
    expect(attempt.failure!.reason, GridDetectionFailureReason.imageTooSmall);
  });
}
