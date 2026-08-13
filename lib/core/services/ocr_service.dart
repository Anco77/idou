import 'dart:io';
import 'package:flutter_tesseract_ocr/flutter_tesseract_ocr.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import '../utils/grid_detector.dart';
export '../utils/grid_detector.dart';

class MardIdResult {
  final int col;
  final int row;
  final String mardId;
  final int x1;
  final int y1;
  final int x2;
  final int y2;
  final double confidence;
  MardIdResult(this.col, this.row, this.mardId,
      {this.x1 = 0,
      this.y1 = 0,
      this.x2 = 0,
      this.y2 = 0,
      this.confidence = 0});
}

class OcrService {
  List<MardIdResult> parseHocr(
    String hocr, {
    required int cropW,
    required int cropH,
    required int gridCols,
    required int gridRows,
    int upsampleFactor = 2,
  }) {
    final hocrRegex = RegExp(r'<span\b([^>]*)>(.*?)</span>',
        caseSensitive: false, dotAll: true);
    final cellW = cropW / gridCols;
    final cellH = cropH / gridRows;
    final textRegex = RegExp(r'^([A-M])(\d+)$');
    final results = <MardIdResult>[];
    final seenCells = <int>{};

    for (final match in hocrRegex.allMatches(hocr)) {
      final attributes = match.group(1)!;
      if (!RegExp(r'''\bclass\s*=\s*["'][^"']*ocrx?_word''',
              caseSensitive: false)
          .hasMatch(attributes)) {
        continue;
      }
      final title =
          RegExp(r'''\btitle\s*=\s*["']([^"']*)["']''', caseSensitive: false)
              .firstMatch(attributes)
              ?.group(1);
      final bbox = title == null
          ? null
          : RegExp(r'\bbbox\s+(\d+)\s+(\d+)\s+(\d+)\s+(\d+)',
                  caseSensitive: false)
              .firstMatch(title);
      if (bbox == null) continue;
      final x1 = int.parse(bbox.group(1)!);
      final y1 = int.parse(bbox.group(2)!);
      final x2 = int.parse(bbox.group(3)!);
      final y2 = int.parse(bbox.group(4)!);
      final rawText = match
          .group(2)!
          .replaceAll(RegExp(r'<[^>]+>'), '')
          .replaceAll('&nbsp;', '')
          .trim();
      final cx = ((x1 + x2) / 2) / upsampleFactor;
      final cy = ((y1 + y2) / 2) / upsampleFactor;
      if (cx < 0 || cx >= cropW || cy < 0 || cy >= cropH) continue;

      final col = (cx / cellW).floor();
      final row = (cy / cellH).floor();
      if (col < 0 || col >= gridCols || row < 0 || row >= gridRows) continue;
      final cellKey = row * gridCols + col;
      if (!seenCells.add(cellKey)) continue;

      var text = rawText.toUpperCase().replaceAll(RegExp(r'[^A-Z0-9]'), '');
      if (text.length >= 2) {
        final prefix = text[0]
            .replaceAll('8', 'B')
            .replaceAll('6', 'G')
            .replaceAll('0', 'D');
        final digits = text
            .substring(1)
            .replaceAll('O', '0')
            .replaceAll('I', '1')
            .replaceAll('L', '1')
            .replaceAll('S', '5');
        text = '$prefix$digits';
      }
      final parsed = textRegex.firstMatch(text);
      if (parsed == null) continue;
      final number = int.tryParse(parsed.group(2)!);
      if (number == null || number < 1 || number > 99) continue;
      final confidence = double.tryParse(
            RegExp(r'x_wconf\s+(\d+(?:\.\d+)?)', caseSensitive: false)
                    .firstMatch(title ?? '')
                    ?.group(1) ??
                '',
          ) ??
          0;
      results.add(MardIdResult(col, row, '${parsed.group(1)}$number',
          x1: x1,
          y1: y1,
          x2: x2,
          y2: y2,
          confidence: (confidence / 100).clamp(0, 1)));
    }
    return results;
  }

  Future<List<MardIdResult>> recognizeMardIds(
    String imagePath,
    int cropX,
    int cropY,
    int cropW,
    int cropH,
    int gridCols,
    int gridRows,
  ) async {
    final fileBytes = await File(imagePath).readAsBytes();
    final image = img.decodeImage(fileBytes);
    if (image == null) return [];

    final cropped = img.copyCrop(
      image,
      x: cropX,
      y: cropY,
      width: cropW,
      height: cropH,
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

    return parseHocr(
      hocr,
      cropW: cropW,
      cropH: cropH,
      gridCols: gridCols,
      gridRows: gridRows,
      upsampleFactor: us,
    );
  }

  Future<GridDetectionResult?> detectGrid(String imagePath) async {
    final bytes = await File(imagePath).readAsBytes();
    final image = img.decodeImage(bytes);
    if (image == null) return null;
    return GridDetector.detect(image);
  }
}
