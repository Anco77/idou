import 'package:drift/drift.dart';
import 'color_standards_table.dart';
import 'patterns_table.dart';

class InventoryLogs extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get colorId => integer().named('color_id').references(ColorStandards, #colorId)();
  TextColumn get changeType => text().named('change_type')();
  IntColumn get quantity => integer()();  // 正数=增加(补货), 负数=减少(消耗)
  IntColumn get resultQty => integer().named('result_qty')();
  TextColumn get patternId => text().named('pattern_id').references(Patterns, #id).nullable()();
  DateTimeColumn get createdAt => dateTime().named('created_at').withDefault(currentDateAndTime)();

}
