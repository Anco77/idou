import '../lib/domain/models/bead_color.dart';
import '../lib/domain/models/pattern.dart';
import '../lib/domain/services/editor_commands.dart';
import '../lib/domain/services/editor_quality.dart';

void main() {
  final red = BeadColor(
    id: 1,
    code: 'A1',
    displayName: 'A1',
    red: 255,
    green: 0,
    blue: 0,
  );
  final blue = BeadColor(
    id: 2,
    code: 'A2',
    displayName: 'A2',
    red: 0,
    green: 0,
    blue: 255,
  );
  final redCell = PatternCell(color: red, source: CellSource.ocr, confidence: .4);
  final blueCell = PatternCell(color: blue, source: CellSource.manual);
  var grid = PatternGrid(1, 50, [List<PatternCell?>.filled(50, null)]);
  final stack = EditorCommandStack();

  for (var column = 0; column < 50; column++) {
    grid = stack.execute(SetCellCommand(0, column, null, redCell), grid);
  }
  assert(stack.undoDepth == 50);
  assert(grid.occupiedCount == 50);
  assert(grid.consumptions[1] == 50);

  for (var column = 0; column < 50; column++) {
    grid = stack.undo(grid);
  }
  assert(grid.occupiedCount == 0);
  assert(stack.canRedo);

  grid = stack.execute(
    FillCellsCommand(
      [(0, 0, null), (0, 1, null), (0, 2, null)],
      blueCell,
    ),
    grid,
  );
  assert(grid.consumptions[2] == 3);
  assert(findLowConfidenceCells(grid).isEmpty);

  grid = stack.execute(
    SetCellCommand(0, 3, null, redCell),
    grid,
  );
  assert(findLowConfidenceCells(grid).single.column == 3);
  final merged = MergeCellsCommand(
    [(0, 3, redCell)],
    blueCell,
  );
  grid = stack.execute(merged, grid);
  assert(grid.consumptions[1] == null);
  assert(grid.consumptions[2] == 4);

  print('pure editor regression passed');
}
