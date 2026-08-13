import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:idou/core/database/app_database.dart';
import 'package:idou/core/database/daos/inventory_dao.dart';
import 'package:idou/data/repositories/inventory_repository_impl.dart';
import 'package:idou/presentation/pages/inventory/bulk_inventory_page.dart';

void main() {
  testWidgets('insufficient batch shows every shortage and keeps selection',
      (tester) async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);
    final repository = InventoryRepositoryImpl(InventoryDao(db));
    await repository.restock(1, 3);
    await repository.restock(2, 2);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [databaseProvider.overrideWithValue(db)],
        child: const MaterialApp(home: BulkInventoryPage()),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.chevron_right).first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('A1'));
    await tester.tap(find.text('A2'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('消耗 (2)'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(ChoiceChip, '5'));
    await tester.pump();
    await tester.tap(find.text('确认 (5 颗)'));
    await tester.pumpAndSettle();

    expect(find.text('批量操作未执行'), findsOneWidget);
    expect(find.text('A1'), findsWidgets);
    expect(find.text('需要 5，现有 3，缺少 2'), findsOneWidget);
    expect(find.text('A2'), findsWidgets);
    expect(find.text('需要 5，现有 2，缺少 3'), findsOneWidget);
    expect(find.text('消耗 (2)'), findsOneWidget);
    expect(find.textContaining('已消耗'), findsNothing);
  });

  testWidgets('database failure does not show success or clear selection',
      (tester) async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);
    final repository = InventoryRepositoryImpl(InventoryDao(db));
    await repository.restock(1, 3);
    await db.customStatement(
      'CREATE TRIGGER fail_bulk_log BEFORE INSERT ON inventory_logs '
      "WHEN NEW.change_type = 'consume' "
      "BEGIN SELECT RAISE(ABORT, 'bulk failure'); END",
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [databaseProvider.overrideWithValue(db)],
        child: const MaterialApp(home: BulkInventoryPage()),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.chevron_right).first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('A1'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('消耗 (1)'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('确认 (1 颗)'));
    await tester.pumpAndSettle();

    expect(find.text('批量操作失败，库存未发生变化，请重试'), findsOneWidget);
    expect(find.text('消耗 (1)'), findsOneWidget);
    expect(find.textContaining('已消耗'), findsNothing);
    expect((await repository.getInventory(1))?.currentQty, 3);
  });
}
