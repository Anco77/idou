import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:idou/application/export/export_pattern.dart';
import 'package:idou/domain/models/bead_color.dart';
import 'package:idou/domain/models/pattern.dart';

void main() {
  test('exports a repeatable CSV and JSON grid', () {
    final color = BeadColor(
        id: 1, code: 'A1', displayName: 'A1', red: 1, green: 2, blue: 3);
    final grid = PatternGrid(1, 2, [
      [PatternCell(color: color, source: CellSource.manual), null]
    ]);

    expect(PatternExport.toCsv(grid), 'A1,');
    final json =
        jsonDecode(PatternExport.toJsonString(grid)) as Map<String, dynamic>;
    expect(json['rows'], 1);
    expect(json['cells'][0][0]['colorId'], 1);
    expect(json['cells'][0][1], isNull);
  });
}
