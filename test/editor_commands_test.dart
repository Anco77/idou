import 'package:flutter_test/flutter_test.dart';
import 'package:idou/domain/models/bead_color.dart';
import 'package:idou/domain/models/pattern.dart';
import 'package:idou/domain/services/editor_commands.dart';

void main() {
  test('editor commands preserve undo/redo grid state', () {
    final color = BeadColor(
        id: 1, code: 'A1', displayName: 'A1', red: 1, green: 2, blue: 3);
    final cell = PatternCell(color: color, source: CellSource.manual);
    var grid = PatternGrid(1, 1, [
      [null]
    ]);
    final stack = EditorCommandStack();
    grid = stack.execute(SetCellCommand(0, 0, null, cell), grid);
    expect(grid.occupiedCount, 1);
    grid = stack.undo(grid);
    expect(grid.occupiedCount, 0);
    grid = stack.redo(grid);
    expect(grid.occupiedCount, 1);
  });

  test('multiple edits can be undone and redone in order', () {
    final first = BeadColor(
        id: 1, code: 'A1', displayName: 'A1', red: 1, green: 2, blue: 3);
    final second = BeadColor(
        id: 2, code: 'A2', displayName: 'A2', red: 4, green: 5, blue: 6);
    final a = PatternCell(color: first, source: CellSource.manual);
    final b = PatternCell(color: second, source: CellSource.manual);
    var grid = PatternGrid(1, 2, [
      [null, null]
    ]);
    final stack = EditorCommandStack();
    grid = stack.execute(SetCellCommand(0, 0, null, a), grid);
    grid = stack.execute(SetCellCommand(0, 1, null, b), grid);
    grid = stack.undo(grid);
    expect(grid.cellAt(0, 0)?.color.id, 1);
    expect(grid.cellAt(0, 1), isNull);
    grid = stack.undo(grid);
    expect(grid.occupiedCount, 0);
    grid = stack.redo(grid);
    grid = stack.redo(grid);
    expect(grid.cellAt(0, 1)?.color.id, 2);
  });

  test('fill command and fifty edits preserve exact undo history', () {
    final color = BeadColor(
        id: 1, code: 'A1', displayName: 'A1', red: 1, green: 2, blue: 3);
    final cell = PatternCell(color: color, source: CellSource.manual);
    var grid = PatternGrid(1, 50, [List<PatternCell?>.filled(50, null)]);
    final stack = EditorCommandStack();
    for (var column = 0; column < 50; column++) {
      grid = stack.execute(SetCellCommand(0, column, null, cell), grid);
    }
    expect(stack.undoDepth, 50);
    for (var column = 0; column < 50; column++) {
      grid = stack.undo(grid);
    }
    expect(grid.occupiedCount, 0);
    grid = stack.execute(
      FillCellsCommand(
        [(0, 0, null), (0, 1, null)],
        cell,
      ),
      grid,
    );
    expect(grid.occupiedCount, 2);
    grid = stack.undo(grid);
    expect(grid.occupiedCount, 0);
  });
}
