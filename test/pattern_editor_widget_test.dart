import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:idou/domain/models/bead_color.dart';
import 'package:idou/domain/models/pattern.dart';
import 'package:idou/presentation/controllers/pattern_editor_controller.dart';
import 'package:idou/presentation/widgets/pattern_editor.dart';

void main() {
  testWidgets('editor selects a palette color, edits a cell, and undoes it',
      (tester) async {
    final color = BeadColor(
        id: 1, code: 'A1', displayName: 'A1', red: 255, green: 0, blue: 0);
    final controller = PatternEditorController(PatternGrid(1, 1, [
      [null]
    ]));
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
          body: PatternEditor(controller: controller, palette: [color])),
    ));
    await tester.tap(find.text('A1'));
    await tester.tap(find.byKey(const ValueKey('pattern-cell-0-0')));
    await tester.pump();
    expect(controller.grid.occupiedCount, 1);
    await tester.tap(find.byTooltip('Undo'));
    await tester.pump();
    expect(controller.grid.occupiedCount, 0);
  });
}
