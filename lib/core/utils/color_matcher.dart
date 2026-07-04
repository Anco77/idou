import 'dart:collection';
import 'dart:typed_data';
import 'package:delta_e/delta_e.dart';
import 'package:flutter/material.dart';

class StandardColor {
  final int colorId;
  final String colorName;
  final String hexValue;
  final int r;
  final int g;
  final int b;
  final LabColor lab;

  StandardColor({
    required this.colorId,
    required this.colorName,
    required this.hexValue,
    required this.r,
    required this.g,
    required this.b,
  }) : lab = LabColor.fromRGB(r, g, b);

  Color get flutterColor => Color.fromARGB(255, r, g, b);
}

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

class _Candidate {
  final StandardColor color;
  final double dist;
  _Candidate(this.color, this.dist);
}

void _siftDown(List<_Candidate> heap, int i) {
  final n = heap.length;
  while (true) {
    int largest = i;
    final left = 2 * i + 1;
    final right = 2 * i + 2;
    if (left < n && heap[left].dist > heap[largest].dist) largest = left;
    if (right < n && heap[right].dist > heap[largest].dist) largest = right;
    if (largest == i) break;
    final tmp = heap[i];
    heap[i] = heap[largest];
    heap[largest] = tmp;
    i = largest;
  }
}

class ColorMatcher {
  final List<StandardColor> _standardColors;
  final HashMap<int, LabColor> _labCache = HashMap<int, LabColor>();

  ColorMatcher(this._standardColors);

  StandardColor? getStandardById(int colorId) {
    for (final c in _standardColors) {
      if (c.colorId == colorId) return c;
    }
    return null;
  }

  MatchResult findNearest(int r, int g, int b) {
    final key = (r << 16) | (g << 8) | b;
    final pixelLab = _labCache.putIfAbsent(key, () => LabColor.fromRGB(r, g, b));

    const topN = 5;
    final heap = <_Candidate>[];
    for (final color in _standardColors) {
      final dr = r - color.r;
      final dg = g - color.g;
      final db = b - color.b;
      final d = (dr * dr + dg * dg + db * db).toDouble();
      if (heap.length < topN) {
        heap.add(_Candidate(color, d));
        if (heap.length == topN) {
          for (int i = topN ~/ 2 - 1; i >= 0; i--) _siftDown(heap, i);
        }
      } else if (d < heap[0].dist) {
        heap[0] = _Candidate(color, d);
        _siftDown(heap, 0);
      }
    }

    StandardColor? best;
    double minDistance = double.infinity;
    for (final c in heap) {
      final dist = deltaE00(pixelLab, c.color.lab);
      if (dist < minDistance) {
        minDistance = dist;
        best = c.color;
      }
    }
    return MatchResult(color: best!, distance: minDistance);
  }

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

        if (a < 128) continue;

        final match = findNearest(r, g, b);
        colorCounts[match.color.colorId] = (colorCounts[match.color.colorId] ?? 0) + 1;
      }
    }

    return colorCounts;
  }

  static Map<int, int> pixelsToBeads(Map<int, int> pixelCounts) {
    return Map.fromEntries(
      pixelCounts.entries.map((e) => MapEntry(e.key, e.value)),
    );
  }

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

    final avg = findNearest(sumR ~/ total, sumG ~/ total, sumB ~/ total);
    return avg.color;
  }

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

  Map<int, int> mergeSimilarColors(List<List<StandardColor?>> grid, {double threshold = 10.0}) {
    if (threshold <= 0) {
      final counts = <int, int>{};
      for (final row in grid) {
        for (final cell in row) {
          if (cell != null) {
            counts[cell.colorId] = (counts[cell.colorId] ?? 0) + 1;
          }
        }
      }
      return counts;
    }

    final freq = <int, int>{};
    final colorMap = <int, StandardColor>{};
    for (final row in grid) {
      for (final cell in row) {
        if (cell != null) {
          freq[cell.colorId] = (freq[cell.colorId] ?? 0) + 1;
          colorMap[cell.colorId] = cell;
        }
      }
    }

    final sorted = freq.entries.toList()..sort((a, b) => a.value.compareTo(b.value));

    for (int i = 0; i < sorted.length; i++) {
      final targetId = sorted[i].key;
      if (!freq.containsKey(targetId)) continue;
      final targetLab = colorMap[targetId]?.lab;
      if (targetLab == null) continue;

      int? bestId;
      double bestDist = threshold;
      for (int j = sorted.length - 1; j > i; j--) {
        final candidateId = sorted[j].key;
        if (!freq.containsKey(candidateId)) continue;
        final candidateLab = colorMap[candidateId]?.lab;
        if (candidateLab == null) continue;

        final dist = deltaE00(targetLab, candidateLab);
        if (dist < bestDist) {
          bestDist = dist;
          bestId = candidateId;
        }
      }

      if (bestId != null) {
        int count = 0;
        final mergedColor = colorMap[bestId]!;
        for (int row = 0; row < grid.length; row++) {
          for (int col = 0; col < grid[row].length; col++) {
            if (grid[row][col]?.colorId == targetId) {
              grid[row][col] = mergedColor;
              count++;
            }
          }
        }
        freq[bestId] = (freq[bestId] ?? 0) + count;
        freq.remove(targetId);
      }
    }

    final result = <int, int>{};
    for (final row in grid) {
      for (final cell in row) {
        if (cell != null) {
          result[cell.colorId] = (result[cell.colorId] ?? 0) + 1;
        }
      }
    }
    return result;
  }
}
