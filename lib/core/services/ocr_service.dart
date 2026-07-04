import 'dart:io';
import 'dart:math';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image/image.dart' as img;

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

      const maxDim = 2048;
      const maxUs = 2;
      final us = [
        maxUs,
        (maxDim / image.width).floor(),
        (maxDim / image.height).floor(),
      ].reduce(min).clamp(1, maxUs);

      final upsampled = img.copyResize(
        image,
        width: image.width * us,
        height: image.height * us,
        interpolation: img.Interpolation.nearest,
      );

      final rgba = upsampled.getBytes(order: img.ChannelOrder.rgba);
      final inputImage = InputImage.fromBitmap(
        bitmap: rgba,
        width: upsampled.width,
        height: upsampled.height,
      );

      final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
      final result = await textRecognizer.processImage(inputImage);
      textRecognizer.close();

      final cellW = cropW / gridCols;
      final cellH = cropH / gridRows;
      final textRegex = RegExp(r'^([A-M])(\d+)$');
      final results = <MardIdResult>[];
      final seenCells = <int>{};

      for (final block in result.blocks) {
        final box = block.boundingBox;

        final cx = box.center.dx / us;
        final cy = box.center.dy / us;
        if (cx < cropX || cx >= cropX + cropW) continue;
        if (cy < cropY || cy >= cropY + cropH) continue;

        final relX = cx - cropX;
        final relY = cy - cropY;
        final col = (relX / cellW).round();
        final row = (relY / cellH).round();
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
    } catch (_) {
      return [];
    }
  }
}
