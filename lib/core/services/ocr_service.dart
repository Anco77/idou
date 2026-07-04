import 'dart:typed_data';
import 'dart:ui';
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
    img.Image image,
    int gridCols,
    int gridRows,
  ) async {
    const maxDim = 2048;
    const maxUs = 3;
    final scale = maxDim / (image.width > image.height ? image.width : image.height);
    final us = scale < maxUs ? (scale.floor()).clamp(1, maxUs) : maxUs;

    final upsampled = img.copyResize(
      image,
      width: image.width * us,
      height: image.height * us,
      interpolation: img.Interpolation.nearest,
    );

    final rgba = upsampled.getBytes(order: img.ChannelOrder.rgba);
    final bgra = Uint8List(rgba.length);
    for (int i = 0; i < rgba.length; i += 4) {
      bgra[i] = rgba[i + 2];
      bgra[i + 1] = rgba[i + 1];
      bgra[i + 2] = rgba[i];
      bgra[i + 3] = rgba[i + 3];
    }

    final inputImage = InputImage.fromBytes(
      bytes: bgra,
      metadata: InputImageMetadata(
        size: Size(upsampled.width.toDouble(), upsampled.height.toDouble()),
        rotation: InputImageRotation.rotation0deg,
        format: InputImageFormat.bgra8888,
        bytesPerRow: upsampled.width * 4,
      ),
    );

    final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
    final result = await textRecognizer.processImage(inputImage);
    textRecognizer.close();

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
