import 'package:drift/drift.dart';

class Patterns extends Table {
  TextColumn get id => text()();
  TextColumn get title => text()();
  TextColumn get originalImage => text().named('original_image')();
  DateTimeColumn get uploadTime => dateTime().named('upload_time')();
  DateTimeColumn get completeTime => dateTime().named('complete_time').nullable()();
  TextColumn get completePhotos => text().named('complete_photos').nullable()();  // JSON array
  TextColumn get status => text().withDefault(const Constant('pending'))();
  TextColumn get source => text()();
  DateTimeColumn get createdAt => dateTime().named('created_at').withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}
