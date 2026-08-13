import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:idou/core/database/daos/patterns_dao.dart';

void main() {
  test('PatternItem preserves schema v3 grid and inventory fields', () {
    final item = PatternItem(
      id: 'p1',
      title: 'demo',
      originalImage: '/assets/p1.png',
      uploadTime: _date,
      status: 'pending',
      source: 'manual',
      createdAt: _date,
      paletteId: 'mard-221',
      rows: 2,
      cols: 2,
      grid: '[[1,null],[2,3]]',
      previewImage: '/assets/p1-preview.png',
      recognitionSummary: '{"confidence":0.9}',
    );
    final restored = PatternItem.fromMap(
        jsonDecode(jsonEncode(item.toMap())) as Map<String, dynamic>);
    expect(restored.rows, 2);
    expect(restored.cols, 2);
    expect(restored.grid, contains('null'));
    expect(restored.inventoryDeducted, isFalse);
  });
}

final _date = DateTime(2026, 1, 1);
