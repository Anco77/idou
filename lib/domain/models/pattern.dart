import 'bead_color.dart';
import 'palette.dart';

enum CellSource { ocr, color, manual, generated }

enum PatternSource { recognition, generated, imported }

class PatternCell {
  final BeadColor color;
  final CellSource source;
  final double confidence;

  PatternCell(
      {required this.color, required this.source, this.confidence = 1}) {
    if (confidence < 0 || confidence > 1) {
      throw ArgumentError.value(confidence, 'confidence', '必须在 0 到 1 之间');
    }
  }

  PatternCell copyWith(
          {BeadColor? color, CellSource? source, double? confidence}) =>
      PatternCell(
        color: color ?? this.color,
        source: source ?? this.source,
        confidence: confidence ?? this.confidence,
      );
}

class PatternGrid {
  final int rows;
  final int columns;
  final List<List<PatternCell?>> cells;

  PatternGrid(this.rows, this.columns, List<List<PatternCell?>> cells)
      : cells = List.unmodifiable(
          cells.map((row) => List<PatternCell?>.unmodifiable(row)),
        ) {
    if (rows < 1 ||
        columns < 1 ||
        cells.length != rows ||
        cells.any((row) => row.length != columns)) {
      throw ArgumentError('网格尺寸与单元数据不一致');
    }
  }

  int get occupiedCount =>
      consumptions.values.fold(0, (sum, count) => sum + count);

  Map<int, int> get consumptions {
    final counts = <int, int>{};
    for (final row in cells) {
      for (final cell in row) {
        if (cell != null) {
          counts[cell.color.id] = (counts[cell.color.id] ?? 0) + 1;
        }
      }
    }
    return Map.unmodifiable(counts);
  }

  PatternCell? cellAt(int row, int column) {
    _validatePosition(row, column);
    return cells[row][column];
  }

  PatternGrid withCell(int row, int column, PatternCell? cell) {
    _validatePosition(row, column);
    final updated = cells.map((items) => items.toList()).toList();
    updated[row][column] = cell;
    return PatternGrid(rows, columns, updated);
  }

  void _validatePosition(int row, int column) {
    if (row < 0 || row >= rows || column < 0 || column >= columns) {
      throw RangeError('网格坐标越界: ($row, $column)');
    }
  }
}

class PatternDraft {
  final String id;
  final String title;
  final PatternSource sourceType;
  final Palette palette;
  final PatternGrid grid;

  const PatternDraft({
    required this.id,
    required this.title,
    required this.sourceType,
    required this.palette,
    required this.grid,
  });

  PatternDraft copyWith({String? title, PatternGrid? grid}) => PatternDraft(
        id: id,
        title: title ?? this.title,
        sourceType: sourceType,
        palette: palette,
        grid: grid ?? this.grid,
      );
}
