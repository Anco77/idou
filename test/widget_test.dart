import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:idou/app.dart';

void main() {
  testWidgets('App builds smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: IdouApp()));

    expect(find.byType(IdouApp), findsOneWidget);
  });
}