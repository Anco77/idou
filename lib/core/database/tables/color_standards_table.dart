import 'package:drift/drift.dart';

class ColorStandards extends Table {
  IntColumn get colorId => integer().named('color_id')();
  TextColumn get colorName => text().named('color_name')();
  TextColumn get hexValue => text().named('hex_value')();
  IntColumn get r => integer()();
  IntColumn get g => integer()();
  IntColumn get b => integer()();
  IntColumn get defaultQty => integer().named('default_qty').withDefault(const Constant(1200))();

  @override
  Set<Column> get primaryKey => {colorId};
}
