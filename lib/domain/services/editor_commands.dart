import '../models/pattern.dart';

abstract interface class EditorCommand {
  PatternGrid apply(PatternGrid grid);
  PatternGrid undo(PatternGrid grid);
}

class SetCellCommand implements EditorCommand {
  final int row;
  final int column;
  final PatternCell? before;
  final PatternCell? after;

  const SetCellCommand(this.row, this.column, this.before, this.after);

  @override
  PatternGrid apply(PatternGrid grid) => grid.withCell(row, column, after);

  @override
  PatternGrid undo(PatternGrid grid) => grid.withCell(row, column, before);
}

class FillCellsCommand implements EditorCommand {
  final List<(int row, int column, PatternCell? before)> changes;
  final PatternCell? after;

  const FillCellsCommand(this.changes, this.after);

  @override
  PatternGrid apply(PatternGrid grid) {
    var result = grid;
    for (final change in changes) {
      result = result.withCell(change.$1, change.$2, after);
    }
    return result;
  }

  @override
  PatternGrid undo(PatternGrid grid) {
    var result = grid;
    for (final change in changes) {
      result = result.withCell(change.$1, change.$2, change.$3);
    }
    return result;
  }
}

class ConfirmCellCommand implements EditorCommand {
  final int row;
  final int column;
  final PatternCell before;
  final PatternCell after;

  const ConfirmCellCommand(this.row, this.column, this.before, this.after);

  @override
  PatternGrid apply(PatternGrid grid) => grid.withCell(row, column, after);

  @override
  PatternGrid undo(PatternGrid grid) => grid.withCell(row, column, before);
}

class MergeCellsCommand implements EditorCommand {
  final List<(int row, int column, PatternCell before)> changes;
  final PatternCell replacement;

  const MergeCellsCommand(this.changes, this.replacement);

  @override
  PatternGrid apply(PatternGrid grid) {
    var result = grid;
    for (final change in changes) {
      result = result.withCell(change.$1, change.$2, replacement);
    }
    return result;
  }

  @override
  PatternGrid undo(PatternGrid grid) {
    var result = grid;
    for (final change in changes) {
      result = result.withCell(change.$1, change.$2, change.$3);
    }
    return result;
  }
}

class MergeColorCommand implements EditorCommand {
  final int fromColorId;
  final PatternCell replacement;
  final List<(int row, int column, PatternCell before)> changes;

  const MergeColorCommand(this.fromColorId, this.replacement, this.changes);

  @override
  PatternGrid apply(PatternGrid grid) {
    var result = grid;
    for (final change in changes) {
      result = result.withCell(change.$1, change.$2, replacement);
    }
    return result;
  }

  @override
  PatternGrid undo(PatternGrid grid) {
    var result = grid;
    for (final change in changes) {
      result = result.withCell(change.$1, change.$2, change.$3);
    }
    return result;
  }
}

class EditorCommandStack {
  final List<EditorCommand> _undo = [];
  final List<EditorCommand> _redo = [];

  PatternGrid execute(EditorCommand command, PatternGrid grid) {
    final result = command.apply(grid);
    _undo.add(command);
    _redo.clear();
    return result;
  }

  PatternGrid undo(PatternGrid grid) {
    if (_undo.isEmpty) return grid;
    final command = _undo.removeLast();
    _redo.add(command);
    return command.undo(grid);
  }

  PatternGrid redo(PatternGrid grid) {
    if (_redo.isEmpty) return grid;
    final command = _redo.removeLast();
    _undo.add(command);
    return command.apply(grid);
  }

  bool get canUndo => _undo.isNotEmpty;
  bool get canRedo => _redo.isNotEmpty;

  int get undoDepth => _undo.length;
}
