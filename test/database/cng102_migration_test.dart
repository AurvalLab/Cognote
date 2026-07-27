import 'dart:io';

import 'package:cognote/src/database/cognote_database.dart';
import 'package:drift/drift.dart' show Variable;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as path;
import 'package:sqlite3/sqlite3.dart' as sqlite;

void main() {
  test(
    'real v1 database migrates to v2 and remains stable after reopen',
    () async {
      final directory = await Directory.systemTemp.createTemp(
        'cognote_cng102_migration_',
      );
      final file = File(path.join(directory.path, 'cognote.sqlite'));
      const principalId = 'migration-principal';
      const deviceId = 'migration-device';
      const publicInstallId = 'migration-install';
      final createdAt = DateTime.utc(2026, 7, 25).millisecondsSinceEpoch;
      final lastSeenAt = DateTime.utc(2026, 7, 26).millisecondsSinceEpoch;

      try {
        final v1 = sqlite.sqlite3.open(file.path);
        try {
          v1.execute('PRAGMA foreign_keys = ON');
          v1.execute('''
          CREATE TABLE principals (
            id TEXT NOT NULL PRIMARY KEY,
            kind TEXT NOT NULL,
            status TEXT NOT NULL,
            home_region TEXT NOT NULL,
            data_residency TEXT NOT NULL,
            created_at INTEGER NOT NULL,
            upgraded_at INTEGER
          )
        ''');
          v1.execute('''
          CREATE TABLE device_identities (
            id TEXT NOT NULL PRIMARY KEY,
            principal_id TEXT NOT NULL UNIQUE
              REFERENCES principals(id) ON DELETE RESTRICT,
            public_install_id TEXT NOT NULL UNIQUE,
            created_at INTEGER NOT NULL,
            last_seen_at INTEGER NOT NULL
          )
        ''');
          v1.execute('''
          CREATE UNIQUE INDEX one_active_anonymous_principal
          ON principals (kind, status)
          WHERE kind = 'anonymous' AND status = 'active'
        ''');
          v1.execute(
            'INSERT INTO principals '
            '(id, kind, status, home_region, data_residency, created_at) '
            "VALUES (?, 'anonymous', 'active', 'cn-mainland', 'cn', ?)",
            [principalId, createdAt],
          );
          v1.execute(
            'INSERT INTO device_identities '
            '(id, principal_id, public_install_id, created_at, last_seen_at) '
            'VALUES (?, ?, ?, ?, ?)',
            [deviceId, principalId, publicInstallId, createdAt, lastSeenAt],
          );
          v1.execute('PRAGMA user_version = 1');
        } finally {
          v1.close();
        }

        await _openAndVerifyV2(
          file,
          principalId: principalId,
          deviceId: deviceId,
          publicInstallId: publicInstallId,
          createdAt: createdAt,
          lastSeenAt: lastSeenAt,
          insertNewRows: true,
        );
        await _openAndVerifyV2(
          file,
          principalId: principalId,
          deviceId: deviceId,
          publicInstallId: publicInstallId,
          createdAt: createdAt,
          lastSeenAt: lastSeenAt,
          insertNewRows: false,
        );
      } finally {
        await _deleteDirectoryWhenReleased(directory);
      }
    },
  );

  test(
    'migration failure propagates and does not delete or rebuild v1 data',
    () async {
      final directory = await Directory.systemTemp.createTemp(
        'cognote_cng102_failed_migration_',
      );
      final file = File(path.join(directory.path, 'cognote.sqlite'));

      try {
        final v1 = sqlite.sqlite3.open(file.path);
        try {
          v1.execute('''
          CREATE TABLE principals (
            id TEXT NOT NULL PRIMARY KEY,
            kind TEXT NOT NULL,
            status TEXT NOT NULL,
            home_region TEXT NOT NULL,
            data_residency TEXT NOT NULL,
            created_at INTEGER NOT NULL,
            upgraded_at INTEGER
          )
        ''');
          v1.execute('''
          CREATE TABLE device_identities (
            id TEXT NOT NULL PRIMARY KEY,
            principal_id TEXT NOT NULL UNIQUE
              REFERENCES principals(id) ON DELETE RESTRICT,
            public_install_id TEXT NOT NULL UNIQUE,
            created_at INTEGER NOT NULL,
            last_seen_at INTEGER NOT NULL
          )
        ''');
          v1.execute(
            'INSERT INTO principals '
            '(id, kind, status, home_region, data_residency, created_at) '
            "VALUES ('preserved-principal', 'anonymous', 'active', "
            "'cn-mainland', 'cn', 1)",
          );
          v1.execute('PRAGMA user_version = 1');
        } finally {
          v1.close();
        }

        final database = CognoteDatabase(
          NativeDatabase(
            file,
            setup: (rawDatabase) {
              rawDatabase.execute('PRAGMA query_only = ON');
            },
          ),
        );
        try {
          await expectLater(
            database.customSelect('SELECT 1').getSingle(),
            throwsA(anything),
          );
        } finally {
          await database.close();
        }

        expect(file.existsSync(), isTrue);
        final preserved = sqlite.sqlite3.open(file.path);
        try {
          final principal = preserved.select(
            "SELECT id FROM principals WHERE id = 'preserved-principal'",
          );
          final version = preserved.select('PRAGMA user_version');
          final observations = preserved.select(
            "SELECT name FROM sqlite_master "
            "WHERE type = 'table' AND name IN ('observations', 'local_assets')",
          );
          expect(principal, hasLength(1));
          expect(version.first['user_version'], 1);
          expect(observations, isEmpty);
        } finally {
          preserved.close();
        }
      } finally {
        await _deleteDirectoryWhenReleased(directory);
      }
    },
  );
}

Future<void> _openAndVerifyV2(
  File file, {
  required String principalId,
  required String deviceId,
  required String publicInstallId,
  required int createdAt,
  required int lastSeenAt,
  required bool insertNewRows,
}) async {
  final database = CognoteDatabase(NativeDatabase(file));
  try {
    final version = await database
        .customSelect('PRAGMA user_version')
        .getSingle();
    expect(version.read<int>('user_version'), 3);

    final principal = await database
        .customSelect(
          'SELECT * FROM principals WHERE id = ?',
          variables: [Variable<String>(principalId)],
        )
        .getSingle();
    expect(principal.read<String>('id'), principalId);
    expect(principal.read<String>('kind'), 'anonymous');
    expect(principal.read<String>('status'), 'active');
    expect(principal.read<String>('home_region'), 'cn-mainland');
    expect(principal.read<String>('data_residency'), 'cn');
    expect(principal.read<int>('created_at'), createdAt);
    expect(principal.readNullable<int>('upgraded_at'), isNull);

    final device = await database
        .customSelect(
          'SELECT * FROM device_identities WHERE id = ?',
          variables: [Variable<String>(deviceId)],
        )
        .getSingle();
    expect(device.read<String>('id'), deviceId);
    expect(device.read<String>('principal_id'), principalId);
    expect(device.read<String>('public_install_id'), publicInstallId);
    expect(device.read<int>('created_at'), createdAt);
    expect(device.read<int>('last_seen_at'), lastSeenAt);

    for (final table in ['observations', 'local_assets']) {
      final result = await database
          .customSelect(
            "SELECT name FROM sqlite_master WHERE type = 'table' AND name = ?",
            variables: [Variable<String>(table)],
          )
          .get();
      expect(result, hasLength(1), reason: '$table must exist after migration');
    }

    if (insertNewRows) {
      final now = DateTime.utc(2026, 7, 26).millisecondsSinceEpoch;
      await database.customStatement(
        'INSERT INTO observations '
        '(id, owner_id, input_type, raw_text, captured_at, timezone_offset, '
        'privacy_level, cloud_ai_policy, sync_policy, created_by_device_id, '
        'created_at, updated_at) '
        "VALUES ('migration-observation', ?, 'text', NULL, ?, 480, "
        "'normal', 'local_only', 'local_only', ?, ?, ?)",
        [principalId, now, deviceId, now, now],
      );
      await database.customStatement(
        'INSERT INTO local_assets '
        '(id, observation_id, local_uri, local_original_present, mime_type, '
        'bytes, sha256, exif_removed, upload_state, created_at, updated_at) '
        "VALUES ('migration-asset', 'migration-observation', "
        "'file:///migration.jpg', 1, 'image/jpeg', 1, 'migration-hash', 1, "
        "'local_only', ?, ?)",
        [now, now],
      );
    }

    final observationCount = await database
        .customSelect('SELECT COUNT(*) AS count FROM observations')
        .getSingle();
    final assetCount = await database
        .customSelect('SELECT COUNT(*) AS count FROM local_assets')
        .getSingle();
    expect(observationCount.read<int>('count'), 1);
    expect(assetCount.read<int>('count'), 1);
  } finally {
    await database.close();
  }
}

Future<void> _deleteDirectoryWhenReleased(Directory directory) async {
  for (var attempt = 0; attempt < 10; attempt++) {
    try {
      await directory.delete(recursive: true);
      return;
    } on PathAccessException {
      if (attempt == 9) {
        rethrow;
      }
      await Future<void>.delayed(const Duration(milliseconds: 50));
    }
  }
}
