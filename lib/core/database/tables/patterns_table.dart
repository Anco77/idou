import 'package:drift/drift.dart';

class Patterns extends Table {
  TextColumn get id => text()();
  TextColumn get title => text()();
  TextColumn get originalImage => text().named('original_image')();
  DateTimeColumn get uploadTime => dateTime().named('upload_time')();
  DateTimeColumn get completeTime =>
      dateTime().named('complete_time').nullable()();
  TextColumn get completePhotos =>
      text().named('complete_photos').nullable()(); // JSON array
  TextColumn get status => text().withDefault(const Constant('pending'))();
  TextColumn get source => text()();
  DateTimeColumn get createdAt =>
      dateTime().named('created_at').withDefault(currentDateAndTime)();
  TextColumn get paletteId => text().named('palette_id').nullable()();
  IntColumn get rows => integer().withDefault(const Constant(0))();
  IntColumn get cols => integer().withDefault(const Constant(0))();
  TextColumn get grid => text().nullable()();
  BoolColumn get inventoryDeducted => boolean()
      .named('inventory_deducted')
      .withDefault(const Constant(false))();
  TextColumn get previewImage => text().named('preview_image').nullable()();
  TextColumn get recognitionSummary =>
      text().named('recognition_summary').nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
