import '../models/pattern.dart';

class LowConfidenceCell {
  final int row;
  final int column;
  final PatternCell cell;

  const LowConfidenceCell(this.row, this.column, this.cell);
}

List<LowConfidenceCell> findLowConfidenceCells(
  PatternGrid grid, {
  double threshold = .7,
}) {
  final result = <LowConfidenceCell>[];
  for (var row = 0; row < grid.rows; row++) {
    for (var column = 0; column < grid.columns; column++) {
      final cell = grid.cellAt(row, column);
      if (cell != null && cell.confidence < threshold) {
        result.add(LowConfidenceCell(row, column, cell));
      }
    }
  }
  return result;
}
