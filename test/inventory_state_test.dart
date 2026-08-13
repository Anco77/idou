import 'package:flutter_test/flutter_test.dart';
import 'package:idou/core/database/daos/inventory_dao.dart';

void main() {
  final item = InventoryWithColor(
    colorId: 12,
    colorName: 'Mard_B12',
    hexValue: '#ffffff',
    r: 255,
    g: 255,
    b: 255,
    currentQty: 40,
    updatedAt: DateTime(2026),
  );

  test('low-stock status uses the caller threshold', () {
    expect(item.isLowStockAt(50), isTrue);
    expect(item.isLowStockAt(20), isFalse);
  });

  test('search matches MARD code, name and exact internal id', () {
    expect(item.matches('b12'), isTrue);
    expect(item.matches('mard'), isTrue);
    expect(item.matches('12'), isTrue);
    expect(item.matches('13'), isFalse);
  });
}
