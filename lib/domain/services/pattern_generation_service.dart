import 'dart:io';
import 'dart:typed_data';
import 'package:image/image.dart' as img;
import '../../core/utils/color_matcher.dart';

/// 板型定义
enum BoardType {
  small('小板', 52, 2704),
  medium('中板', 78, 6084),
  large('大板', 104, 10816);

  final String label;
  final int size;
  final int totalBeads;
  const BoardType(this.label, this.size, this.totalBeads);
}

/// 生成结果
class GenerationResult {
  final String sourceImagePath;
  final BoardType boardType;
  final List<List<StandardColor>> grid; // [row][col]
  final Map<int, int> materialList; // colorId -> count
  final img.Image previewImage;

  int get totalBeads => boardType.totalBeads;

  const GenerationResult({
    required this.sourceImagePath,
    required this.boardType,
    required this.grid,
    required this.materialList,
    required this.previewImage,
  });
}

/// AI图纸生成服务 — 照片转拼豆图纸
class PatternGenerationService {
  final ColorMatcher _colorMatcher;

  PatternGenerationService(this._colorMatcher);

  /// 从照片生成拼豆图纸
  /// [imagePath] 照片路径
  /// [cropRect] 裁剪区域 {x, y, width, height}
  /// [boardType] 选择的板型
  Future<GenerationResult> generate({
    required String imagePath,
    required CropRect cropRect,
    required BoardType boardType,
  }) async {
    // 1. 加载图像
    final file = File(imagePath);
    final imageBytes = await file.readAsBytes();
    final image = img.decodeImage(imageBytes);
    if (image == null) throw Exception('无法解码图像');

    // 2. 裁剪主体区域
    final cropped = img.copyCrop(
      image,
      x: cropRect.x.round(),
      y: cropRect.y.round(),
      width: cropRect.width.round(),
      height: cropRect.height.round(),
    );

    // 3. 缩放到板型尺寸
    final resized = img.copyResize(cropped,
        width: boardType.size, height: boardType.size);

    // 4. 获取像素数据
    final pixels = Uint8List.fromList(resized.getBytes());

    // 5. 网格匹配
    final grid = _colorMatcher.gridMatch(
      pixels, resized.width, resized.height, boardType.size,
    );

    // 6. 统计用料
    final materialList = <int, int>{};
    for (final row in grid) {
      for (final color in row) {
        materialList[color.colorId] = (materialList[color.colorId] ?? 0) + 1;
      }
    }

    // 7. 生成预览图
    final preview = _generatePreviewImage(grid, boardType);

    return GenerationResult(
      sourceImagePath: imagePath,
      boardType: boardType,
      grid: grid,
      materialList: materialList,
      previewImage: preview,
    );
  }

  /// 生成预览网格图（每个格子用色号颜色填充+网格线）
  img.Image _generatePreviewImage(List<List<StandardColor>> grid, BoardType boardType) {
    const cellSize = 8; // 预览时每个格子8像素
    final previewSize = boardType.size * cellSize;
    final preview = img.Image(width: previewSize + 1, height: previewSize + 1);

    // 填充颜色
    for (int row = 0; row < boardType.size; row++) {
      for (int col = 0; col < boardType.size; col++) {
        final color = grid[row][col];
        final r = color.r;
        final g = color.g;
        final b = color.b;
        for (int dy = 0; dy < cellSize; dy++) {
          for (int dx = 0; dx < cellSize; dx++) {
            preview.setPixel(
              col * cellSize + dx,
              row * cellSize + dy,
              img.ColorRgb8(r, g, b),
            );
          }
        }
      }
    }

    // 画网格线
    final gridColor = img.ColorRgb8(200, 200, 200);
    for (int i = 0; i <= boardType.size; i++) {
      final pos = i * cellSize;
      // 水平线
      for (int x = 0; x < previewSize + 1; x++) {
        if (pos <= previewSize) preview.setPixel(x, pos, gridColor);
      }
      // 垂直线
      for (int y = 0; y < previewSize + 1; y++) {
        if (pos <= previewSize) preview.setPixel(pos, y, gridColor);
      }
    }

    return preview;
  }

  /// 替换网格中单个格子的颜色
  GenerationResult replaceColor(
    GenerationResult result, int row, int col, StandardColor newColor
  ) {
    final newGrid = List<List<StandardColor>>.from(
      result.grid.map((r) => List<StandardColor>.from(r)),
    );
    newGrid[row][col] = newColor;

    // 重新计算用料
    final newMaterialList = <int, int>{};
    for (final r in newGrid) {
      for (final c in r) {
        newMaterialList[c.colorId] = (newMaterialList[c.colorId] ?? 0) + 1;
      }
    }

    // 重新生成预览图
    final preview = _generatePreviewImage(newGrid, result.boardType);

    return GenerationResult(
      sourceImagePath: result.sourceImagePath,
      boardType: result.boardType,
      grid: newGrid,
      materialList: newMaterialList,
      previewImage: preview,
    );
  }
}

/// 裁剪矩形
class CropRect {
  final double x, y, width, height;
  const CropRect({required this.x, required this.y, required this.width, required this.height});
}
