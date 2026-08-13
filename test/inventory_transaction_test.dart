import 'package:flutter_test/flutter_test.dart';
import 'package:drift/native.dart';
import 'package:idou/core/database/app_database.dart';
import 'package:idou/core/database/daos/inventory_dao.dart';
import 'package:idou/data/repositories/inventory_repository_impl.dart';

void main() {
  test('single-color restock upserts after inventory is empty', () async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);
    final repository = InventoryRepositoryImpl(InventoryDao(db));

    await repository.clearAllData();
    expect(await repository.restock(1, 12), isTrue);

    final item = await repository.getInventory(1);
    expect(item?.currentQty, 12);
    expect((await repository.getLogsForColor(1)).single.quantity, 12);
  });

  test('negative or zero quantities are rejected without writes', () async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);
    final repository = InventoryRepositoryImpl(InventoryDao(db));

    expect(await repository.restock(1, 0), isFalse);
    expect(await repository.consume(1, -1), isFalse);
    await expectLater(repository.setQty(1, -5), throwsArgumentError);
  });

  test('consume never makes inventory negative', () async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);
    final repository = InventoryRepositoryImpl(InventoryDao(db));

    await repository.restock(1, 3);
    expect(await repository.consume(1, 4), isFalse);
    expect((await repository.getInventory(1))?.currentQty, 3);
    expect((await repository.getLogsForColor(1)).length, 1);
  });

  test('log failure rolls back the balance update', () async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);
    final repository = InventoryRepositoryImpl(InventoryDao(db));

    await repository.restock(1, 3);
    await db.customStatement(
      "CREATE TRIGGER fail_inventory_log BEFORE INSERT ON inventory_logs "
      "WHEN NEW.change_type = 'consume' BEGIN SELECT RAISE(ABORT, 'log failure'); END",
    );
    await expectLater(
      repository.consume(1, 1),
      throwsA(isA<Exception>()),
    );
    expect((await repository.getInventory(1))?.currentQty, 3);
    expect((await repository.getLogsForColor(1)).length, 1);
  });
}
