import 'dart:io';
import 'dart:math';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';

class MardIdResult {
  final int col;
  final int row;
  final String mardId;
  MardIdResult(this.col, this.row, this.mardId);
}

class OcrService {
  Future<List<MardIdResult>> recognizeMardIds(
    img.Image image,
    int gridCols,
    int gridRows,
  ) async {
    const maxOcrDim = 4096;
    const maxUs = 3;
    final us = [
      maxUs,
      (maxOcrDim / image.width).floor(),
      (maxOcrDim / image.height).floor(),
    ].reduce(min).clamp(1, maxUs);

    final upsampled = img.copyResize(
      image,
      width: image.width * us,
      height: image.height * us,
      interpolation: img.Interpolation.nearest,
    );

    final tempDir = await getTemporaryDirectory();
    final tempFile = File(
      '${tempDir.path}/ocr_temp_${DateTime.now().millisecondsSinceEpoch}.png',
    );
    await tempFile.writeAsBytes(img.encodePng(upsampled));

    final inputImage = InputImage.fromFile(tempFile);
    final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
    final result = await textRecognizer.processImage(inputImage);
    textRecognizer.close();

    try {
      await tempFile.delete();
    } catch (_) {}

    final cellW = upsampled.width / gridCols;
    final cellH = upsampled.height / gridRows;
    final textRegex = RegExp(r'^([A-M])(\d+)$');
    final results = <MardIdResult>[];
    final seenCells = <int>{};

    for (final block in result.blocks) {
      final box = block.boundingBox;
      final col = (box.left / cellW).round();
      final row = (box.top / cellH).round();
      if (col < 0 || col >= gridCols || row < 0 || row >= gridRows) continue;

      final cellKey = row * gridCols + col;
      if (seenCells.contains(cellKey)) continue;

      var text = block.text.trim().toUpperCase();
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
  }
}
