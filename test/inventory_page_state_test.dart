import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:idou/core/database/daos/inventory_dao.dart';
import 'package:idou/core/services/user_settings_service.dart';
import 'package:idou/domain/repositories/inventory_repository.dart';
import 'package:idou/domain/services/inventory_service.dart';
import 'package:idou/presentation/pages/inventory/inventory_page.dart';
import 'package:idou/presentation/providers/inventory_providers.dart';
import 'package:idou/presentation/providers/settings_providers.dart';

class _MemorySettingsService extends UserSettingsService {
  @override
  Future<void> load() async {}

  @override
  Future<void> save(UserSettings settings) async {}
}

class _InventoryRepositoryStub implements InventoryRepository {
  _InventoryRepositoryStub(this._load);

  final Future<List<InventoryWithColor>> Function() _load;
  int loadCount = 0;

  @override
  Future<List<InventoryWithColor>> getAllInventory() {
    loadCount++;
    return _load();
  }

  @override
  Future<List<InventoryWithColor>> getLowStockColors({int threshold = 500}) =>
      throw UnimplementedError();

  @override
  Future<BatchAdjustResult> batchAdjust(Map<int, int> quantities,
          {required bool restock}) =>
      throw UnimplementedError();

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

InventoryWithColor _item({int quantity = 50}) => InventoryWithColor(
      colorId: 1,
      colorName: 'Mard_A1',
      hexValue: '#ffffff',
      r: 255,
      g: 255,
      b: 255,
      currentQty: quantity,
      updatedAt: DateTime(2026),
    );

ProviderContainer _container(_InventoryRepositoryStub repository) {
  return ProviderContainer(
    overrides: [
      userSettingsServiceProvider.overrideWithValue(_MemorySettingsService()),
      inventoryServiceProvider.overrideWithValue(InventoryService(repository)),
    ],
  );
}

Widget _app(_InventoryRepositoryStub repository) {
  return ProviderScope(
    overrides: [
      userSettingsServiceProvider.overrideWithValue(_MemorySettingsService()),
      inventoryServiceProvider.overrideWithValue(InventoryService(repository)),
    ],
    child: const MaterialApp(home: InventoryPage()),
  );
}

void main() {
  test('threshold change immediately recomputes low-stock state', () async {
    final repository = _InventoryRepositoryStub(() async => [_item()]);
    final container = _container(repository);
    addTearDown(container.dispose);

    container.read(inventoryStateProvider);
    await Future<void>.delayed(Duration.zero);
    expect(container.read(inventoryStateProvider).lowStockItems, hasLength(1));

    await container
        .read(userSettingsProvider.notifier)
        .setLowStockThreshold(20);

    final state = container.read(inventoryStateProvider);
    expect(state.lowStockThreshold, 20);
    expect(state.lowStockItems, isEmpty);
    expect(repository.loadCount, 1);
  });

  testWidgets('inventory page exposes loading state', (tester) async {
    final completer = Completer<List<InventoryWithColor>>();
    final repository = _InventoryRepositoryStub(() => completer.future);

    await tester.pumpWidget(_app(repository));
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    completer.complete(const []);
    await tester.pumpAndSettle();
  });

  testWidgets('inventory page exposes empty state', (tester) async {
    final repository = _InventoryRepositoryStub(() async => const []);

    await tester.pumpWidget(_app(repository));
    await tester.pumpAndSettle();

    expect(find.text('暂无库存数据'), findsOneWidget);
  });

  testWidgets('inventory error can retry and clears stale error',
      (tester) async {
    var fail = true;
    final repository = _InventoryRepositoryStub(() async {
      if (fail) throw StateError('load failed');
      return [_item(quantity: 800)];
    });

    await tester.pumpWidget(_app(repository));
    await tester.pumpAndSettle();
    expect(find.text('库存加载失败'), findsOneWidget);
    expect(find.text('重试'), findsOneWidget);

    fail = false;
    await tester.tap(find.text('重试'));
    await tester.pumpAndSettle();

    expect(find.text('库存加载失败'), findsNothing);
    expect(find.text('黄色系'), findsOneWidget);
    expect(repository.loadCount, 2);
  });
}
