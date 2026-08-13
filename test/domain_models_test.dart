import 'package:flutter_test/flutter_test.dart';
import 'package:idou/domain/models/bead_color.dart';
import 'package:idou/domain/models/palette.dart';
import 'package:idou/domain/models/pattern.dart';

void main() {
  group('Palette', () {
    test('looks up colours without inventory state', () {
      final palette = Palette(
        id: 'mard-221',
        name: 'MARD 221',
        colors: [
          BeadColor(
              id: 1,
              code: 'A1',
              displayName: 'Black',
              red: 0,
              green: 0,
              blue: 0),
          BeadColor(
              id: 2,
              code: 'B1',
              displayName: 'White',
              red: 255,
              green: 255,
              blue: 255),
        ],
      );

      expect(palette.byId(2)!.code, 'B1');
      expect(palette.byCode('a1')!.id, 1);
      expect(palette.byId(999), isNull);
    });
  });

  group('PatternGrid', () {
    final black = BeadColor(
        id: 1, code: 'A1', displayName: 'Black', red: 0, green: 0, blue: 0);
    final white = BeadColor(
        id: 2,
        code: 'B1',
        displayName: 'White',
        red: 255,
        green: 255,
        blue: 255);

    test('counts occupied cells and ignores blanks', () {
      final grid = PatternGrid(2, 3, [
        [
          PatternCell(color: black, source: CellSource.generated),
          null,
          PatternCell(color: white, source: CellSource.color),
        ],
        [null, PatternCell(color: black, source: CellSource.ocr), null],
      ]);

      expect(grid.occupiedCount, 3);
      expect(grid.consumptions, {1: 2, 2: 1});
    });

    test('manual override returns a new grid and preserves original', () {
      final grid = PatternGrid(1, 1, [
        [PatternCell(color: black, source: CellSource.ocr, confidence: .4)],
      ]);

      final updated = grid.withCell(
          0, 0, PatternCell(color: white, source: CellSource.manual));

      expect(grid.cellAt(0, 0)!.color.id, 1);
      expect(updated.cellAt(0, 0)!.color.id, 2);
      expect(updated.cellAt(0, 0)!.source, CellSource.manual);
    });

    test('rejects non-rectangular cells', () {
      expect(
        () => PatternGrid(2, 2, [
          [null, null],
          [null]
        ]),
        throwsArgumentError,
      );
    });
  });

  test('PatternDraft exposes a safe immutable editing snapshot', () {
    final color = BeadColor(
        id: 1, code: 'A1', displayName: 'Black', red: 0, green: 0, blue: 0);
    final palette = Palette(id: 'p', name: 'Palette', colors: [color]);
    final draft = PatternDraft(
      id: 'draft-1',
      title: 'Test',
      sourceType: PatternSource.generated,
      palette: palette,
      grid: PatternGrid(1, 1, [
        [PatternCell(color: color, source: CellSource.generated)]
      ]),
    );

    expect(draft.grid.consumptions, {1: 1});
    expect(draft.copyWith(title: 'Edited').title, 'Edited');
    expect(draft.copyWith(title: 'Edited').grid, same(draft.grid));
  });
}
