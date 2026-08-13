import 'package:flutter_test/flutter_test.dart';
import 'package:idou/domain/models/bead_color.dart';
import 'package:idou/domain/models/pattern.dart';
import 'package:idou/domain/services/editor_quality.dart';
import 'package:idou/presentation/controllers/pattern_editor_controller.dart';

void main() {
  test('low-confidence filter returns exact grid coordinates', () {
    final color = BeadColor(
        id: 1, code: 'A1', displayName: 'A1', red: 1, green: 2, blue: 3);
    final grid = PatternGrid(1, 2, [
      [
        PatternCell(color: color, source: CellSource.ocr, confidence: .4),
        PatternCell(color: color, source: CellSource.manual, confidence: .9),
      ]
    ]);
    final result = findLowConfidenceCells(grid);
    expect(result, hasLength(1));
    expect(result.single.row, 0);
    expect(result.single.column, 0);
  });

  test('confirmed low-confidence cell becomes manual and undoable', () {
    final color = BeadColor(
        id: 1, code: 'A1', displayName: 'A1', red: 1, green: 2, blue: 3);
    final before =
        PatternCell(color: color, source: CellSource.ocr, confidence: .4);
    var grid = PatternGrid(1, 1, [
      [before]
    ]);
    final controller = PatternEditorController(grid);
    controller.confirmCell(0, 0);
    expect(controller.grid.cellAt(0, 0)!.source, CellSource.manual);
    expect(controller.grid.cellAt(0, 0)!.confidence, 1);
    controller.undo();
    expect(controller.grid.cellAt(0, 0)!.source, CellSource.ocr);
  });

  test(
      'merge command replaces only the selected source color and is reversible',
      () {
    final first = BeadColor(
        id: 1, code: 'A1', displayName: 'A1', red: 1, green: 2, blue: 3);
    final second = BeadColor(
        id: 2, code: 'A2', displayName: 'A2', red: 4, green: 5, blue: 6);
    final grid = PatternGrid(1, 3, [
      [
        PatternCell(color: first, source: CellSource.color),
        PatternCell(color: first, source: CellSource.color),
        PatternCell(color: second, source: CellSource.color),
      ]
    ]);
    final controller = PatternEditorController(grid);
    controller.mergeColor(
        1, PatternCell(color: second, source: CellSource.manual));
    expect(
        controller.grid.cells.first.map((cell) => cell?.color.id), [2, 2, 2]);
    controller.undo();
    expect(
        controller.grid.cells.first.map((cell) => cell?.color.id), [1, 1, 2]);
  });
}
