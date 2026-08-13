import 'dart:convert';

import '../../domain/models/pattern.dart';

class PatternExport {
  const PatternExport._();

  static String toCsv(PatternGrid grid) {
    return grid.cells
        .map((row) => row.map((cell) => cell?.color.code ?? '').join(','))
        .join('\n');
  }

  static Map<String, Object?> toJson(PatternGrid grid) => {
        'rows': grid.rows,
        'columns': grid.columns,
        'cells': grid.cells
            .map((row) => row
                .map((cell) => cell == null
                    ? null
                    : {
                        'colorId': cell.color.id,
                        'code': cell.color.code,
                        'source': cell.source.name,
                        'confidence': cell.confidence,
                      })
                .toList())
            .toList(),
      };

  static String toJsonString(PatternGrid grid) => jsonEncode(toJson(grid));
}
