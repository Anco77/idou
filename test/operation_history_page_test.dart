import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:idou/core/database/app_database.dart';
import 'package:idou/core/database/daos/inventory_dao.dart';
import 'package:idou/data/repositories/inventory_repository_impl.dart';
import 'package:idou/presentation/pages/inventory/operation_history_page.dart';

void main() {
  testWidgets('pattern movement opens pattern and can be reversed once',
      (tester) async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);
    final repository = InventoryRepositoryImpl(InventoryDao(db));
    await _insertPattern(db, 'p1');
    await repository.restock(1, 10);
    await repository.batchDeduct({1: 4}, patternId: 'p1');

    final router = GoRouter(
      initialLocation: '/history',
      routes: [
        GoRoute(
          path: '/history',
          builder: (_, __) => const OperationHistoryPage(),
        ),
        GoRoute(
          path: '/patterns/detail/:id',
          builder: (_, state) => Text('pattern:${state.pathParameters['id']}'),
        ),
        GoRoute(
          path: '/inventory/detail/:id',
          builder: (_, state) => Text('color:${state.pathParameters['id']}'),
        ),
      ],
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [databaseProvider.overrideWithValue(db)],
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('A1').first);
    await tester.pumpAndSettle();
    expect(find.text('pattern:p1'), findsOneWidget);

    router.go('/history');
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('冲正'));
    await tester.pumpAndSettle();
    expect(find.text('冲正图纸扣除'), findsOneWidget);
    await tester.tap(find.text('确认冲正'));
    await tester.pumpAndSettle();

    expect(find.text('冲正成功，原流水已保留'), findsOneWidget);
    final logs = await repository.getLogsForColor(1);
    expect(
        logs.where((log) => log.changeType == 'deduct_pattern'), hasLength(1));
    expect(logs.where((log) => log.changeType == 'reversal'), hasLength(1));
    expect((await repository.getInventory(1))?.currentQty, 10);
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
