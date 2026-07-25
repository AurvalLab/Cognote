import 'package:drift/drift.dart';

class Principals extends Table {
  TextColumn get id => text()();
  TextColumn get kind => text()();
  TextColumn get status => text()();
  TextColumn get homeRegion => text()();
  TextColumn get dataResidency => text()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get upgradedAt => dateTime().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
