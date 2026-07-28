import 'package:drift/drift.dart';

import '../../../identity/data/tables/device_identities.dart';
import '../../../identity/data/tables/principals.dart';

@DataClassName('OutboxOperationRow')
class OutboxOperations extends Table {
  TextColumn get operationId => text()();
  TextColumn get ownerId =>
      text().references(Principals, #id, onDelete: KeyAction.restrict)();
  TextColumn get deviceId =>
      text().references(DeviceIdentities, #id, onDelete: KeyAction.restrict)();
  TextColumn get aggregateType => text()();
  TextColumn get aggregateId => text()();
  TextColumn get operationKind => text()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  List<String> get customConstraints => [
    "CHECK (aggregate_type = 'observation')",
    "CHECK (operation_kind IN ('observation_upsert', 'observation_delete'))",
  ];

  @override
  Set<Column<Object>> get primaryKey => {operationId};
}
