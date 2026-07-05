import 'dart:io';
import 'dart:math';
import 'package:image/image.dart' as img;
import '../lib/core/utils/grid_detector.dart';

void main(List<String> args) async {
  final path = args.isNotEmpty ? args[0] : 'test_grid.jpg';
  if (!File(path).existsSync()) {
    print('文件不存在: $path');
    return;
  }
  final bytes = await File(path).readAsBytes();
  final image = img.decodeImage(bytes);
  if (image == null) {
    print('无法解码图片');
    return;
  }
  print('图片: $path');
  print('尺寸: ${image.width} × ${image.height}');
  print('');

  final result = GridDetector.detect(image);
  if (result != null) {
    print('✓ 检测成功!');
    print('  crop: (${result.cropX},${result.cropY}) ${result.cropW}×${result.cropH}');
    print('  grid: ${result.gridCols}×${result.gridRows}');
    return;
  }

  print('✗ GridDetector 返回 null');
  print('');
  print('=== 手动跟踪 detectAxis ===');
  traceDetect(image);
  print('');
  print('=== 标准诊断 ===');
  diagnostic(image);
}

void traceDetect(img.Image image) {
  const varianceThreshold = 50.0;
  const sampleStep = 2;
  const mergeDist = 3;

  List<int> detectAxis(int axis) {
    final len = axis == 0 ? image.width : image.height;
    final other = axis == 0 ? image.height : image.width;

    final isLine = <bool>[];
    for (int i = 0; i < other; i++) {
      double sumR = 0, sumG = 0, sumB = 0;
      int n = 0;
      for (int j = 0; j < len; j += sampleStep) {
        final px = axis == 0 ? image.getPixel(j, i) : image.getPixel(i, j);
        sumR += px.r; sumG += px.g; sumB += px.b; n++;
      }
      if (n == 0) { isLine.add(false); continue; }
      final aR = sumR / n, aG = sumG / n, aB = sumB / n;
      double va = 0; int vn = 0;
      for (int j = 0; j < len; j += sampleStep) {
        final px = axis == 0 ? image.getPixel(j, i) : image.getPixel(i, j);
        va += (px.r - aR) * (px.r - aR) +
            (px.g - aG) * (px.g - aG) +
            (px.b - aB) * (px.b - aB);
        vn++;
      }
      isLine.add(vn > 0 && sqrt(va / vn) < varianceThreshold);
    }

    // Find line center positions
    final centers = <int>[];
    int s = -1;
    for (int i = 0; i <= isLine.length; i++) {
      if (i < isLine.length && isLine[i]) { if (s < 0) s = i; }
      else if (s >= 0) { centers.add((s + i - 1) ~/ 2); s = -1; }
    }
    print('  axis=$axis: centers=${centers.length}');
    if (centers.length >= 10) {
      print('   前10centers: ${centers.take(10).toList()}');
      print('   后10centers: ${centers.skip(centers.length-10).toList()}');
    }
    if (centers.length < 4) return [];

    // Merge
    final merged = <int>[centers[0]];
    for (int i = 1; i < centers.length; i++) {
      if (centers[i] - merged.last > mergeDist) merged.add(centers[i]);
    }
    print('  merged=${merged.length}');
    if (merged.length >= 10) {
      print('   前10merged: ${merged.take(10).toList()}');
    }
    if (merged.length < 4) return [];

    // Compute gaps from inner 80%
    final margin = max(1, merged.length ~/ 10);
    final inner = merged.sublist(margin, merged.length - margin);
    print('  inner=${inner.length}, margin=$margin');
    if (inner.length < 3) return [];

    final gaps = <int>[];
    for (int i = 1; i < inner.length; i++) gaps.add(inner[i] - inner[i - 1]);
    print('  innerGaps=${gaps.length}');
    if (gaps.isNotEmpty) {
      print('  innerGaps前10: ${gaps.take(10).toList()}');
      final sorted = [...gaps]..sort();
      final cellSize = sorted[sorted.length ~/ 2];
      print('  medianGap=$cellSize');
    }
    return [];
  }

  print('Horizontal:');
  detectAxis(0);
  print('Vertical:');
  detectAxis(1);
}

void diagnostic(img.Image image) {
  const step = 2;
  const threshold = 50.0;
  const mergeDist = 3;

  List<int> findRows(int axis) {
    final len = axis == 0 ? image.width : image.height;
    final other = axis == 0 ? image.height : image.width;
    final rows = <int>[];
    for (int i = 0; i < other; i++) {
      double sumR = 0, sumG = 0, sumB = 0;
      int n = 0;
      for (int j = 0; j < len; j += step) {
        final px = axis == 0 ? image.getPixel(j, i) : image.getPixel(i, j);
        sumR += px.r;
        sumG += px.g;
        sumB += px.b;
        n++;
      }
      if (n == 0) continue;
      final aR = sumR / n, aG = sumG / n, aB = sumB / n;
      double va = 0;
      int vn = 0;
      for (int j = 0; j < len; j += step) {
        final px = axis == 0 ? image.getPixel(j, i) : image.getPixel(i, j);
        va += (px.r - aR) * (px.r - aR) +
            (px.g - aG) * (px.g - aG) +
            (px.b - aB) * (px.b - aB);
        vn++;
      }
      if (vn == 0) continue;
      final variance = sqrt(va / vn);
      if (variance < threshold) {
        rows.add(i);
      }
    }
    return rows;
  }

  void printRows(String label, List<int> rows) {
    if (rows.isEmpty) {
      print('$label: 空 (没有均匀行)');
      return;
    }
    final merged = <int>[rows[0]];
    for (int i = 1; i < rows.length; i++) {
      if (rows[i] - merged.last > mergeDist) {
        merged.add(rows[i]);
      }
    }
    final gaps = <int>[];
    for (int i = 1; i < merged.length; i++) {
      gaps.add(merged[i] - merged[i - 1]);
    }
    print('$label:');
    print('  原始均匀行: ${rows.length} 行');
    print('  前10均匀行: ${rows.take(10).toList()}');
    print('  后10均匀行: ${rows.skip(max(0, rows.length - 10)).toList()}');
    print('  合并后行数: ${merged.length} 行');
    print('  前10合并: ${merged.take(min(10, merged.length)).toList()}');
    print('  后10合并: ${merged.skip(max(0, merged.length - 10)).toList()}');
    if (gaps.isNotEmpty) {
      print('  gap数量: ${gaps.length}');
      print('  前10gap: ${gaps.take(10).toList()}');
      print('  gap范围: ${gaps.reduce(min)} ~ ${gaps.reduce(max)}');
      print('  平均gap: ${gaps.reduce((a, b) => a + b) ~/ gaps.length}');
    }
  }

  printRows('水平方向(横线)', findRows(0));
  print('');
  printRows('垂直方向(竖线)', findRows(1));
}
