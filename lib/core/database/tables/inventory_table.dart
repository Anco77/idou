import 'package:drift/drift.dart';
import 'color_standards_table.dart';

class Inventory extends Table {
  IntColumn get colorId => integer().named('color_id').references(ColorStandards, #colorId)();
  IntColumn get currentQty => integer().named('current_qty').withDefault(const Constant(0))();
  DateTimeColumn get updatedAt => dateTime().named('updated_at').withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {colorId};
}
