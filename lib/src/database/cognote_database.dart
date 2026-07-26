import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

import '../identity/data/tables/device_identities.dart';
import '../identity/data/tables/principals.dart';
import '../observation/data/tables/local_assets.dart';
import '../observation/data/tables/observations.dart';

part 'cognote_database.g.dart';

@DriftDatabase(
  tables: [Principals, DeviceIdentities, Observations, LocalAssets],
)
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
  int get schemaVersion => 2;

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
    onUpgrade: (migrator, from, to) async {
      if (from < 2) {
        await migrator.createTable(observations);
        await migrator.createTable(localAssets);
      }
    },
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON');
      await customStatement('PRAGMA busy_timeout = 5000');
    },
  );
}
