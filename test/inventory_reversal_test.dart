import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:idou/core/database/app_database.dart';
import 'package:idou/core/database/daos/inventory_dao.dart';
import 'package:idou/data/repositories/inventory_repository_impl.dart';

void main() {
  test('reversal creates a new movement and preserves original history',
      () async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);
    final repository = InventoryRepositoryImpl(InventoryDao(db));

    await _insertPattern(db, 'p1');
    await repository.restock(1, 10);
    final deduction = await repository.batchDeduct({1: 4}, patternId: 'p1');
    expect(deduction.success, isTrue);
    final original = (await repository.getLogsForColor(1))
        .singleWhere((log) => log.changeType == 'deduct_pattern');
    expect(await repository.reverseLog(original.id), isTrue);
    expect(await repository.reverseLog(original.id), isFalse);

    final logs = await repository.getLogsForColor(1);
    expect(logs.length, 3);
    expect(logs.any((log) => log.id == original.id), isTrue);
    expect(logs.first.changeType, 'reversal');
    expect(logs.first.patternId, 'p1');
    expect((await repository.getInventory(1))?.currentQty, 10);
  });

  test('ordinary inventory movement cannot be reversed', () async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);
    final repository = InventoryRepositoryImpl(InventoryDao(db));

    await repository.restock(1, 10);
    final restock = (await repository.getLogsForColor(1)).single;

    expect(await repository.reverseLog(restock.id), isFalse);
    expect((await repository.getInventory(1))?.currentQty, 10);
    expect((await repository.getLogsForColor(1)), hasLength(1));
  });
}

Future<void> _insertPattern(AppDatabase db, String id) {
  final now = DateTime(2026).toIso8601String();
  return db.customInsert(
    'INSERT INTO patterns '
    '(id, title, original_image, upload_time, status, source, created_at, inventory_deducted) '
    'VALUES (?, ?, ?, ?, ?, ?, ?, ?)',
    variables: [
      Variable(id),
      const Variable('test'),
      const Variable('/test.png'),
      Variable(now),
      const Variable('pending'),
      const Variable('test'),
      Variable(now),
      Variable.withInt(1),
    ],
  );
}
