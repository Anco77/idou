import 'dart:typed_data';
import 'package:flutter/material.dart';

/// 标准色号数据
class StandardColor {
  final int colorId;
  final String colorName;
  final String hexValue;
  final int r;
  final int g;
  final int b;

  const StandardColor({
    required this.colorId,
    required this.colorName,
    required this.hexValue,
    required this.r,
    required this.g,
    required this.b,
  });

  Color get flutterColor => Color.fromARGB(255, r, g, b);
}

/// 颜色匹配结果
class MatchResult {
  final StandardColor color;
  final double distance;
  final int pixelCount;

  const MatchResult({
    required this.color,
    required this.distance,
    this.pixelCount = 0,
  });
}

/// 颜色匹配引擎 — RGB欧氏距离
class ColorMatcher {
  final List<StandardColor> _standardColors;

  ColorMatcher(this._standardColors);

  /// 将RGB值匹配到最近的标准色号
  MatchResult findNearest(int r, int g, int b) {
    StandardColor? best;
    double minDistance = double.infinity;

    for (final color in _standardColors) {
      final dr = r - color.r;
      final dg = g - color.g;
      final db = b - color.b;
      // RGB欧氏距离（加权，人眼对绿色更敏感）
      final distance = dr * dr * 0.3 + dg * dg * 0.59 + db * db * 0.11;

      if (distance < minDistance) {
        minDistance = distance;
        best = color;
      }
    }

    return MatchResult(
      color: best!,
      distance: minDistance,
    );
  }

  /// 对图像像素数据做颜色量化
  /// [pixels] 为 RGBA 字节数组
  /// 返回 { colorId: pixelCount } 的映射
  Map<int, int> quantizeImage(Uint8List pixels, int width, int height) {
    final Map<int, int> colorCounts = {};

    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        final idx = (y * width + x) * 4;
        if (idx + 3 >= pixels.length) continue;

        final r = pixels[idx];
        final g = pixels[idx + 1];
        final b = pixels[idx + 2];
        final a = pixels[idx + 3];

        // 忽略透明像素
        if (a < 128) continue;

        final match = findNearest(r, g, b);
        colorCounts[match.color.colorId] = (colorCounts[match.color.colorId] ?? 0) + 1;
      }
    }

    return colorCounts;
  }

  /// 将像素点数换算为拼豆颗数
  /// 假设每个像素对应一颗豆（1:1映射）
  static Map<int, int> pixelsToBeads(Map<int, int> pixelCounts) {
    return Map.fromEntries(
      pixelCounts.entries.map((e) => MapEntry(e.key, e.value)),
    );
  }

  /// 计算网格平均颜色
  Color averageGridColor(Uint8List pixels, int width, int height,
      int gridX, int gridY, int gridW, int gridH) {
    int sumR = 0, sumG = 0, sumB = 0, count = 0;

    for (int y = gridY; y < gridY + gridH && y < height; y++) {
      for (int x = gridX; x < gridX + gridW && x < width; x++) {
        final idx = (y * width + x) * 4;
        if (idx + 3 >= pixels.length) continue;
        final a = pixels[idx + 3];
        if (a < 128) continue;

        sumR += pixels[idx];
        sumG += pixels[idx + 1];
        sumB += pixels[idx + 2];
        count++;
      }
    }

    if (count == 0) return Colors.transparent;
    return Color.fromARGB(255, sumR ~/ count, sumG ~/ count, sumB ~/ count);
  }

  /// Mode-pool dominant color matching for a grid cell.
  /// For a list of [r, g, b] pixel values, individually matches each to the
  /// nearest standard color. If the top vote exceeds [threshold] (default 30%),
  /// returns that color. Otherwise falls back to the nearest standard color of
  /// the average pixel color.
  StandardColor gridMatchDominant(List<List<int>> pixelRgbs, {double threshold = 0.3}) {
    final votes = <int, int>{};
    int total = 0;
    int sumR = 0, sumG = 0, sumB = 0;

    for (final rgb in pixelRgbs) {
      if (rgb.length < 3) continue;
      final r = rgb[0], g = rgb[1], b = rgb[2];
      final match = findNearest(r, g, b);
      votes[match.color.colorId] = (votes[match.color.colorId] ?? 0) + 1;
      total++;
      sumR += r; sumG += g; sumB += b;
    }

    if (total == 0) return _standardColors.first;

    final topEntry = votes.entries.reduce((a, b) => a.value > b.value ? a : b);
    final topPct = topEntry.value / total;

    if (topPct >= threshold) {
      return _standardColors.firstWhere((c) => c.colorId == topEntry.key);
    }

    // Fallback: average color → nearest standard
    final avg = findNearest(sumR ~/ total, sumG ~/ total, sumB ~/ total);
    return avg.color;
  }

  /// 网格化图像并匹配色号
  /// 返回 [row][col] 的 StandardColor 矩阵
  List<List<StandardColor>> gridMatch(
    Uint8List pixels, int width, int height, int gridSize
  ) {
    final cellW = width ~/ gridSize;
    final cellH = height ~/ gridSize;
    final result = List.generate(gridSize, (_) => List.filled(gridSize, _standardColors.first));

    for (int row = 0; row < gridSize; row++) {
      for (int col = 0; col < gridSize; col++) {
        final avg = averageGridColor(
          pixels, width, height,
          col * cellW, row * cellH, cellW, cellH,
        );
        if (avg == Colors.transparent) continue;
        final match = findNearest(avg.red, avg.green, avg.blue);
        result[row][col] = match.color;
      }
    }

    return result;
  }
}
