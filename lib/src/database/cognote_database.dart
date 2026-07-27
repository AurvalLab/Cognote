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
  CognoteDatabase(super.executor, {this.beforeFtsMigration});

  final Future<void> Function()? beforeFtsMigration;

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
  int get schemaVersion => 3;

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
      await createObservationSearchSchema();
      await rebuildObservationSearchIndex();
    },
    onUpgrade: (migrator, from, to) async {
      await transaction(() async {
        if (from < 2) {
          await migrator.createTable(observations);
          await migrator.createTable(localAssets);
        }
        if (from < 3) {
          await beforeFtsMigration?.call();
          await createObservationSearchSchema();
          await rebuildObservationSearchIndex();
          final integrity = await customSelect(
            'SELECT COUNT(*) AS count '
            'FROM observation_search_fts AS search '
            'LEFT JOIN observations AS observation '
            'ON observation.id = search.observation_id '
            'WHERE observation.id IS NULL',
          ).getSingle();
          if (integrity.read<int>('count') != 0) {
            throw StateError('Observation search index integrity check failed');
          }
        }
      });
    },
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON');
      await customStatement('PRAGMA busy_timeout = 5000');
    },
  );

  Future<void> createObservationSearchSchema() async {
    await customStatement('''
      CREATE VIRTUAL TABLE IF NOT EXISTS observation_search_fts USING fts5(
        observation_id UNINDEXED,
        raw_text,
        tokenize = 'trigram case_sensitive 0'
      )
    ''');
    await customStatement('''
      CREATE TRIGGER IF NOT EXISTS observation_search_fts_insert
      AFTER INSERT ON observations
      WHEN NEW.raw_text IS NOT NULL
      BEGIN
        INSERT INTO observation_search_fts (observation_id, raw_text)
        VALUES (NEW.id, NEW.raw_text);
      END
    ''');
    await customStatement('''
      CREATE TRIGGER IF NOT EXISTS observation_search_fts_update_raw_text
      AFTER UPDATE OF raw_text ON observations
      BEGIN
        DELETE FROM observation_search_fts
        WHERE observation_id = OLD.id;
        INSERT INTO observation_search_fts (observation_id, raw_text)
        SELECT NEW.id, NEW.raw_text
        WHERE NEW.raw_text IS NOT NULL;
      END
    ''');
    await customStatement('''
      CREATE TRIGGER IF NOT EXISTS observation_search_fts_delete
      AFTER DELETE ON observations
      BEGIN
        DELETE FROM observation_search_fts
        WHERE observation_id = OLD.id;
      END
    ''');
  }

  Future<void> rebuildObservationSearchIndex() async {
    await customStatement('DELETE FROM observation_search_fts');
    await customStatement('''
      INSERT INTO observation_search_fts (observation_id, raw_text)
      SELECT id, raw_text
      FROM observations
      WHERE raw_text IS NOT NULL
    ''');
  }
}
