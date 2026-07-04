import 'dart:io';
import 'dart:math';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;

class MardIdResult {
  final int col;
  final int row;
  final String mardId;
  MardIdResult(this.col, this.row, this.mardId);
}

class OcrService {
  static const _channel = MethodChannel('com.example.idou/ocr');

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
      final blocks = await _channel.invokeMethod<List<dynamic>>(
        'recognizeText',
        {
          'bytes': rgba,
          'width': upsampled.width,
          'height': upsampled.height,
        },
      );

      if (blocks == null) return [];

      final cellW = cropW / gridCols;
      final cellH = cropH / gridRows;
      final textRegex = RegExp(r'^([A-M])(\d+)$');
      final results = <MardIdResult>[];
      final seenCells = <int>{};

      for (final block in blocks) {
        final map = block as Map<dynamic, dynamic>;
        final left = map['left'] as double;
        final right = map['right'] as double;
        final top = map['top'] as double;
        final bottom = map['bottom'] as double;
        final cx = (left + right) / 2 / us;
        final cy = (top + bottom) / 2 / us;
        if (cx < cropX || cx >= cropX + cropW) continue;
        if (cy < cropY || cy >= cropY + cropH) continue;

        final relX = cx - cropX;
        final relY = cy - cropY;
        final col = (relX / cellW).round();
        final row = (relY / cellH).round();
        if (col < 0 || col >= gridCols || row < 0 || row >= gridRows) continue;

        final cellKey = row * gridCols + col;
        if (seenCells.contains(cellKey)) continue;

        var text = (map['text'] as String).trim().toUpperCase();
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
