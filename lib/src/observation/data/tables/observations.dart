import 'package:drift/drift.dart';

import '../../../identity/data/tables/device_identities.dart';
import '../../../identity/data/tables/principals.dart';

class Observations extends Table {
  TextColumn get id => text()();
  TextColumn get ownerId =>
      text().references(Principals, #id, onDelete: KeyAction.restrict)();
  TextColumn get inputType => text()();
  TextColumn get rawText => text().nullable()();
  DateTimeColumn get capturedAt => dateTime()();
  IntColumn get timezoneOffset => integer()();
  TextColumn get privacyLevel => text()();
  TextColumn get cloudAiPolicy => text()();
  TextColumn get syncPolicy => text()();
  TextColumn get createdByDeviceId =>
      text().references(DeviceIdentities, #id, onDelete: KeyAction.restrict)();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();
  IntColumn get serverRevision => integer().nullable()();

  @override
  List<String> get customConstraints => [
    "CHECK (input_type IN ('image', 'text'))",
    'CHECK (timezone_offset BETWEEN -840 AND 840)',
    "CHECK (privacy_level = 'normal')",
    "CHECK (cloud_ai_policy IN ('local_only', 'consent_required', 'allowed'))",
    "CHECK (sync_policy IN ('local_only', 'sync_enabled'))",
  ];

  @override
  Set<Column<Object>> get primaryKey => {id};
}
