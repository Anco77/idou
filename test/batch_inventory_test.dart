import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:idou/core/database/app_database.dart';
import 'package:idou/core/database/daos/inventory_dao.dart';
import 'package:idou/data/repositories/inventory_repository_impl.dart';
import 'package:idou/domain/repositories/inventory_repository.dart';
import 'package:idou/domain/services/inventory_service.dart';
import 'package:idou/presentation/providers/inventory_providers.dart';

class _CountingInventoryRepository implements InventoryRepository {
  int loadCount = 0;
  int batchCount = 0;

  @override
  Future<List<InventoryWithColor>> getAllInventory() async {
    loadCount++;
    return const [];
  }

  @override
  Future<BatchAdjustResult> batchAdjust(
    Map<int, int> quantities, {
    required bool restock,
  }) async {
    batchCount++;
    return BatchAdjustResult(
      success: true,
      adjustedCount: quantities.length,
    );
  }

  @override
  Future<List<InventoryWithColor>> getLowStockColors({int threshold = 500}) =>
      Future.value(const []);

  @override
  Future<DeductResult> batchDeduct(Map<int, int> consumptions,
          {String? patternId}) =>
      throw UnimplementedError();

  @override
  Future<void> clearAllData() => throw UnimplementedError();

  @override
  Future<bool> consume(int colorId, int quantity, {String? patternId}) =>
      throw UnimplementedError();

  @override
  Future<List<OperationLogItem>> getAllLogs(
          {String? changeType,
          int? colorId,
          DateTime? from,
          DateTime? to,
          int limit = 200,
          int offset = 0}) =>
      throw UnimplementedError();

  @override
  Future<InventoryWithColor?> getInventory(int colorId) =>
      throw UnimplementedError();

  @override
  Future<List<InventoryLogItem>> getLogsForColor(int colorId,
          {int limit = 50}) =>
      throw UnimplementedError();

  @override
  Future<void> initializeInventory({int defaultQty = 1200}) =>
      throw UnimplementedError();

  @override
  Future<bool> restock(int colorId, int quantity) => throw UnimplementedError();

  @override
  Future<bool> reverseLog(int logId) => throw UnimplementedError();

  @override
  Future<void> setQty(int colorId, int quantity) => throw UnimplementedError();
}

void main() {
  test('batch adjust is all-or-nothing and returns insufficient details',
      () async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);
    final repository = InventoryRepositoryImpl(InventoryDao(db));
    await repository.restock(1, 3);
    await repository.restock(2, 2);

    final result = await repository.batchAdjust({1: 4, 2: 3}, restock: false);
    expect(result.success, isFalse);
    expect(
      result.insufficientColors
          .map((item) => (
                item.colorId,
                item.required,
                item.available,
              ))
          .toList(),
      [(1, 4, 3), (2, 3, 2)],
    );
    expect((await repository.getInventory(1))?.currentQty, 3);
    expect((await repository.getInventory(2))?.currentQty, 2);
  });

  test('batch restock upserts missing rows in one transaction', () async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);
    final repository = InventoryRepositoryImpl(InventoryDao(db));
    await repository.clearAllData();

    final result = await repository.batchAdjust({1: 4, 2: 5}, restock: true);
    expect(result.success, isTrue);
    expect(result.adjustedCount, 2);
    expect((await repository.getInventory(1))?.currentQty, 4);
    expect((await repository.getInventory(2))?.currentQty, 5);
  });

  test('batch log failure rolls back every balance and movement', () async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);
    final repository = InventoryRepositoryImpl(InventoryDao(db));
    await repository.restock(1, 5);
    await repository.restock(2, 5);
    await db.customStatement(
      'CREATE TRIGGER fail_second_batch_log BEFORE INSERT ON inventory_logs '
      "WHEN NEW.color_id = 2 AND NEW.change_type = 'consume' "
      "BEGIN SELECT RAISE(ABORT, 'batch log failure'); END",
    );

    await expectLater(
      repository.batchAdjust({1: 1, 2: 1}, restock: false),
      throwsA(isA<Exception>()),
    );

    expect((await repository.getInventory(1))?.currentQty, 5);
    expect((await repository.getInventory(2))?.currentQty, 5);
    expect((await repository.getLogsForColor(1)).length, 1);
    expect((await repository.getLogsForColor(2)).length, 1);
  });

  test('conditional update conflict rolls back earlier batch entries',
      () async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);
    final repository = InventoryRepositoryImpl(InventoryDao(db));
    await repository.restock(1, 5);
    await repository.restock(2, 5);
    await db.customStatement(
      'CREATE TRIGGER ignore_second_batch_update BEFORE UPDATE ON inventory '
      'WHEN NEW.color_id = 2 AND NEW.current_qty = 4 '
      'BEGIN SELECT RAISE(IGNORE); END',
    );

    await expectLater(
      repository.batchAdjust({1: 1, 2: 1}, restock: false),
      throwsA(isA<StateError>()),
    );

    expect((await repository.getInventory(1))?.currentQty, 5);
    expect((await repository.getInventory(2))?.currentQty, 5);
    expect((await repository.getLogsForColor(1)).length, 1);
    expect((await repository.getLogsForColor(2)).length, 1);
  });

  test('provider executes one batch and reloads once after success', () async {
    final repository = _CountingInventoryRepository();
    final container = ProviderContainer(
      overrides: [
        inventoryServiceProvider.overrideWithValue(
          InventoryService(repository),
        ),
      ],
    );
    addTearDown(container.dispose);

    container.read(inventoryStateProvider);
    await Future<void>.delayed(Duration.zero);
    final initialLoads = repository.loadCount;

    final result = await container
        .read(inventoryStateProvider.notifier)
        .batchAdjust({1: 2, 2: 3, 3: 4}, restock: true);

    expect(result.success, isTrue);
    expect(repository.batchCount, 1);
    expect(repository.loadCount, initialLoads + 1);
  });
}
