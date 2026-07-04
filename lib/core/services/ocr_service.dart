import 'dart:io';
import 'package:flutter_tesseract_ocr/flutter_tesseract_ocr.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import '../utils/grid_detector.dart';

class MardIdResult {
  final int col;
  final int row;
  final String mardId;
  MardIdResult(this.col, this.row, this.mardId);
}

class OcrService {
  Future<List<MardIdResult>> recognizeMardIds(
    String imagePath,
    int cropX,
    int cropY,
    int cropW,
    int cropH,
    int gridCols,
    int gridRows,
  ) async {
    try {
      final fileBytes = await File(imagePath).readAsBytes();
      final image = img.decodeImage(fileBytes);
      if (image == null) return [];

      GridDetectionResult? detected;

      if (gridCols <= 0 && gridRows <= 0) {
        detected = GridDetector.detect(image);
        if (detected == null) return [];
      }

      final actualCropX = detected?.cropX ?? cropX;
      final actualCropY = detected?.cropY ?? cropY;
      final actualCropW = detected?.cropW ?? cropW;
      final actualCropH = detected?.cropH ?? cropH;
      final actualCols = detected?.gridCols ?? gridCols;
      final actualRows = detected?.gridRows ?? gridRows;

      final cropped = img.copyCrop(
        image,
        x: actualCropX,
        y: actualCropY,
        width: actualCropW,
        height: actualCropH,
      );

      const us = 2;
      final upsampled = img.copyResize(
        cropped,
        width: cropped.width * us,
        height: cropped.height * us,
        interpolation: img.Interpolation.nearest,
      );

      final tempDir = await getTemporaryDirectory();
      final tempFile = File(
        '${tempDir.path}/ocr_${DateTime.now().millisecondsSinceEpoch}.png',
      );
      await tempFile.writeAsBytes(img.encodePng(upsampled));

      final hocr = await FlutterTesseractOcr.extractHocr(
        tempFile.path,
        language: 'eng',
        args: {'psm': '6'},
      );

      try {
        await tempFile.delete();
      } catch (_) {}

      final hocrRegex = RegExp(
        r"span class='ocr_word'.*?bbox (\d+) (\d+) (\d+) (\d+).*?>(.*?)<",
        dotAll: true,
      );

      final cellW = actualCropW / actualCols;
      final cellH = actualCropH / actualRows;
      final textRegex = RegExp(r'^([A-M])(\d+)$');
      final results = <MardIdResult>[];
      final seenCells = <int>{};

      for (final m in hocrRegex.allMatches(hocr)) {
        final x1 = int.parse(m.group(1)!);
        final y1 = int.parse(m.group(2)!);
        final x2 = int.parse(m.group(3)!);
        final y2 = int.parse(m.group(4)!);
        final rawText = m.group(5)!.trim();

        final cx = ((x1 + x2) / 2) / us;
        final cy = ((y1 + y2) / 2) / us;

        final col = (cx / cellW).round();
        final row = (cy / cellH).round();
        if (col < 0 || col >= actualCols || row < 0 || row >= actualRows) continue;

        final cellKey = row * actualCols + col;
        if (seenCells.contains(cellKey)) continue;

        var text = rawText.toUpperCase();
        text = text
            .replaceAll('O', '0')
            .replaceAll('I', '1')
            .replaceAll('S', '5');
        text = text.replaceAll(RegExp(r'[^A-M0-9]'), '');

        final match = textRegex.firstMatch(text);
        if (match == null) continue;

        final mardId = '${match.group(1)}${match.group(2)}';
        results.add(MardIdResult(col, row, mardId));
        seenCells.add(cellKey);
      }

      return results;
    } catch (_) {
      return [];
    }
  }

  Future<GridDetectionResult?> detectGrid(String imagePath) async {
    try {
      final bytes = await File(imagePath).readAsBytes();
      final image = img.decodeImage(bytes);
      if (image == null) return null;
      return GridDetector.detect(image);
    } catch (_) {
      return null;
    }
  }
}
