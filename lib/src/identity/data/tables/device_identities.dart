import 'package:drift/drift.dart';

import 'principals.dart';

class DeviceIdentities extends Table {
  TextColumn get id => text()();
  TextColumn get principalId =>
      text().references(Principals, #id, onDelete: KeyAction.restrict)();
  TextColumn get publicInstallId => text().unique()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get lastSeenAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};

  @override
  List<Set<Column<Object>>> get uniqueKeys => [
    {principalId},
  ];
}
