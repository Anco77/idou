import 'package:drift/native.dart';
import 'package:drift/drift.dart' hide isNull;
import 'package:flutter_test/flutter_test.dart';
import 'package:idou/core/database/app_database.dart';

void main() {
  test('schema v3 stores pattern grid and recognition metadata', () async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);

    expect(db.schemaVersion, 3);
    final columns = await db.customSelect('PRAGMA table_info(patterns)').get();
    final names = columns.map((row) => row.data['name']).cast<String>().toSet();

    expect(
      names,
      containsAll(<String>[
        'palette_id',
        'rows',
        'cols',
        'grid',
        'inventory_deducted',
        'preview_image',
        'recognition_summary',
      ]),
    );
    final foreignKeyViolations =
        await db.customSelect('PRAGMA foreign_key_check').get();
    expect(foreignKeyViolations, isEmpty);
  });

  test('legacy pattern keeps source data without inventing a grid', () async {
    final executor = NativeDatabase.memory(setup: (sqlite) {
      sqlite.execute('''
      CREATE TABLE color_standards (color_id INTEGER PRIMARY KEY, color_name TEXT NOT NULL, hex_value TEXT NOT NULL, r INTEGER NOT NULL, g INTEGER NOT NULL, b INTEGER NOT NULL, default_qty INTEGER NOT NULL DEFAULT 1200);
      CREATE TABLE inventory (color_id INTEGER PRIMARY KEY, current_qty INTEGER NOT NULL DEFAULT 0, updated_at TEXT NOT NULL, FOREIGN KEY (color_id) REFERENCES color_standards(color_id));
      CREATE TABLE inventory_logs (id INTEGER PRIMARY KEY AUTOINCREMENT, color_id INTEGER NOT NULL, change_type TEXT NOT NULL, quantity INTEGER NOT NULL, result_qty INTEGER NOT NULL, pattern_id TEXT, created_at TEXT NOT NULL);
      CREATE TABLE patterns (id TEXT PRIMARY KEY, title TEXT NOT NULL, original_image TEXT NOT NULL, upload_time TEXT NOT NULL, complete_time TEXT, complete_photos TEXT, status TEXT NOT NULL DEFAULT 'pending', source TEXT NOT NULL, created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP);
      CREATE TABLE pattern_consumptions (id INTEGER PRIMARY KEY AUTOINCREMENT, pattern_id TEXT NOT NULL, color_id INTEGER NOT NULL, quantity INTEGER NOT NULL);
      INSERT INTO color_standards VALUES (1, 'MARD A01', '#000000', 0, 0, 0, 1200);
      INSERT INTO patterns (id, title, original_image, upload_time, status, source) VALUES ('legacy-1', '旧图纸', '/legacy.png', '2026-08-13T00:00:00.000', 'pending', 'imported');
      PRAGMA user_version = 2;
    ''');
    });
    final db = AppDatabase.forTesting(executor);
    addTearDown(db.close);

    final row = await db.customSelect(
      'SELECT status, rows, cols, grid FROM patterns WHERE id = ?',
      variables: [Variable('legacy-1')],
    ).getSingle();
    expect(row.data['status'], 'legacy');
    expect(row.data['rows'], 0);
    expect(row.data['cols'], 0);
    expect(row.data['grid'], isNull);
  });

  test('v1 fixture upgrades through v2 and v3 without dropping patterns',
      () async {
    final executor = NativeDatabase.memory(setup: (sqlite) {
      sqlite.execute('''
      CREATE TABLE color_standards (color_id INTEGER PRIMARY KEY, color_name TEXT NOT NULL, hex_value TEXT NOT NULL, r INTEGER NOT NULL, g INTEGER NOT NULL, b INTEGER NOT NULL, default_qty INTEGER NOT NULL DEFAULT 1200);
      CREATE TABLE inventory (color_id INTEGER PRIMARY KEY, current_qty INTEGER NOT NULL DEFAULT 0, updated_at TEXT NOT NULL);
      CREATE TABLE inventory_logs (id INTEGER PRIMARY KEY AUTOINCREMENT, color_id INTEGER NOT NULL, change_type TEXT NOT NULL, quantity INTEGER NOT NULL, result_qty INTEGER NOT NULL, pattern_id TEXT, created_at TEXT NOT NULL);
      CREATE TABLE patterns (id TEXT PRIMARY KEY, title TEXT NOT NULL, original_image TEXT NOT NULL, upload_time TEXT NOT NULL, complete_time TEXT, complete_photos TEXT, status TEXT NOT NULL DEFAULT 'pending', source TEXT NOT NULL, created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP);
      CREATE TABLE pattern_consumptions (id INTEGER PRIMARY KEY AUTOINCREMENT, pattern_id TEXT NOT NULL, color_id INTEGER NOT NULL, quantity INTEGER NOT NULL);
      INSERT INTO color_standards VALUES (1, 'OLD-01', '#000000', 0, 0, 0, 1200);
      INSERT INTO patterns (id, title, original_image, upload_time, status, source) VALUES ('v1-1', 'v1 图纸', '/v1.png', '2026-08-13T00:00:00.000', 'pending', 'imported');
      PRAGMA user_version = 1;
    ''');
    });
    final db = AppDatabase.forTesting(executor);
    addTearDown(db.close);

    final row = await db.customSelect(
      'SELECT title, status, rows, cols, grid FROM patterns WHERE id = ?',
      variables: [Variable('v1-1')],
    ).getSingle();
    expect(row.data['title'], 'v1 图纸');
    expect(row.data['status'], 'legacy');
    expect(row.data['rows'], 0);
    expect(row.data['cols'], 0);
    expect(row.data['grid'], isNull);
    final colors = await db
        .customSelect('SELECT COUNT(*) AS count FROM color_standards')
        .getSingle();
    expect(colors.data['count'], greaterThan(1));
  });
}
