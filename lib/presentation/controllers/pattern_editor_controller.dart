import '../../domain/models/pattern.dart';
import '../../domain/services/editor_commands.dart';
import '../../domain/services/editor_quality.dart';

class PatternEditorController {
  PatternGrid _grid;
  final EditorCommandStack _commands = EditorCommandStack();

  PatternEditorController(this._grid);

  PatternGrid get grid => _grid;
  bool get canUndo => _commands.canUndo;
  bool get canRedo => _commands.canRedo;

  void setCell(int row, int column, PatternCell? cell) {
    final previous = _grid.cellAt(row, column);
    _grid = _commands.execute(
      SetCellCommand(row, column, previous, cell),
      _grid,
    );
  }

  void fillCells(List<(int row, int column)> positions, PatternCell? cell) {
    final changes = positions
        .map((position) =>
            (position.$1, position.$2, _grid.cellAt(position.$1, position.$2)))
        .toList();
    _grid = _commands.execute(FillCellsCommand(changes, cell), _grid);
  }

  void mergeColor(int fromColorId, PatternCell replacement) {
    final changes = <(int row, int column, PatternCell before)>[];
    for (var row = 0; row < _grid.rows; row++) {
      for (var column = 0; column < _grid.columns; column++) {
        final cell = _grid.cellAt(row, column);
        if (cell != null && cell.color.id == fromColorId) {
          changes.add((row, column, cell));
        }
      }
    }
    if (changes.isEmpty) return;
    _grid = _commands.execute(MergeCellsCommand(changes, replacement), _grid);
  }

  void confirmCell(int row, int column) {
    final before = _grid.cellAt(row, column);
    if (before == null || before.confidence >= 1) return;
    final after = before.copyWith(source: CellSource.manual, confidence: 1);
    _grid = _commands.execute(
      ConfirmCellCommand(row, column, before, after),
      _grid,
    );
  }

  List<LowConfidenceCell> lowConfidenceCells({double threshold = .7}) =>
      findLowConfidenceCells(_grid, threshold: threshold);

  void undo() {
    if (!canUndo) return;
    _grid = _commands.undo(_grid);
  }

  void redo() {
    if (!canRedo) return;
    _grid = _commands.redo(_grid);
  }
}
