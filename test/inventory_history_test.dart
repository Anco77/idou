import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:idou/core/database/app_database.dart';
import 'package:idou/core/database/daos/inventory_dao.dart';
import 'package:idou/data/repositories/inventory_repository_impl.dart';

void main() {
  test('history supports controlled type, color, time and pagination',
      () async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);
    final repository = InventoryRepositoryImpl(InventoryDao(db));
    await _insertPattern(db, 'p1');
    await repository.restock(1, 10);
    await repository.consume(1, 1);
    await repository.batchDeduct({1: 2}, patternId: 'p1');
    await repository.restock(2, 5);

    final consume = await repository.getAllLogs(changeType: 'consume');
    expect(
      consume.map((log) => log.changeType).toSet(),
      {'consume', 'deduct_pattern'},
    );
    expect(consume.singleWhere((log) => log.patternId != null).patternId, 'p1');

    final colorTwo = await repository.getAllLogs(colorId: 2);
    expect(colorTwo, hasLength(1));
    expect(colorTwo.single.colorId, 2);

    final firstPage = await repository.getAllLogs(limit: 2);
    final secondPage = await repository.getAllLogs(limit: 2, offset: 2);
    expect(firstPage, hasLength(2));
    expect(secondPage, hasLength(2));
    expect(
      firstPage.map((log) => log.id).toSet().intersection(
            secondPage.map((log) => log.id).toSet(),
          ),
      isEmpty,
    );

    final future = await repository.getAllLogs(from: DateTime(2100));
    expect(future, isEmpty);
  });

  test('history query indexes exist on new and already-current databases',
      () async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);
    await db.customSelect('SELECT 1').get();

    final indexes =
        await db.customSelect('PRAGMA index_list(inventory_logs)').get();
    final names = indexes.map((row) => row.data['name']).toSet();

    expect(names, contains('idx_inventory_logs_pattern'));
    expect(names, contains('idx_inventory_logs_type_created'));
    expect(names, contains('idx_inventory_logs_color_created'));
  });
}

Future<void> _insertPattern(AppDatabase db, String id) {
  final now = DateTime(2026).toIso8601String();
  return db.customInsert(
    'INSERT INTO patterns '
    '(id, title, original_image, upload_time, status, source, created_at) '
    'VALUES (?, ?, ?, ?, ?, ?, ?)',
    variables: [
      Variable(id),
      const Variable('test'),
      const Variable('/test.png'),
      Variable(now),
      const Variable('pending'),
      const Variable('test'),
      Variable(now),
    ],
  );
}
