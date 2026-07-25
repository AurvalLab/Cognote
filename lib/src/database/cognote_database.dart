import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

import '../identity/data/tables/device_identities.dart';
import '../identity/data/tables/principals.dart';

part 'cognote_database.g.dart';

@DriftDatabase(tables: [Principals, DeviceIdentities])
class CognoteDatabase extends _$CognoteDatabase {
  CognoteDatabase(super.executor);

  factory CognoteDatabase.open({Directory? directory}) {
    return CognoteDatabase(
      LazyDatabase(() async {
        final databaseDirectory =
            directory ?? await getApplicationSupportDirectory();
        final file = File(path.join(databaseDirectory.path, 'cognote.sqlite'));
        return NativeDatabase.createInBackground(file);
      }),
    );
  }

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (migrator) async {
      await customStatement('PRAGMA foreign_keys = ON');
      await migrator.createAll();
      await customStatement(
        "CREATE UNIQUE INDEX one_active_anonymous_principal "
        "ON principals (kind, status) "
        "WHERE kind = 'anonymous' AND status = 'active'",
      );
    },
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON');
      await customStatement('PRAGMA busy_timeout = 5000');
    },
  );
}
