import 'package:drift/drift.dart';
import 'color_standards_table.dart';
import 'patterns_table.dart';

class PatternConsumptions extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get patternId => text().named('pattern_id').references(Patterns, #id)();
  IntColumn get colorId => integer().named('color_id').references(ColorStandards, #colorId)();
  IntColumn get quantity => integer()();

  @override
  List<Set<Column>> get uniqueKeys => [
    {patternId, colorId},
  ];
}
