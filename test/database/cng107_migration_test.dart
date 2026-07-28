import 'dart:io';

import 'package:cognote/src/database/cognote_database.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as path;
import 'package:sqlite3/sqlite3.dart' as sqlite;

void main() {
  for (final sourceVersion in [1, 2]) {
    test('real v$sourceVersion database migrates to v3 and reopens', () async {
      final directory = await Directory.systemTemp.createTemp(
        'cng107_v${sourceVersion}_to_v3_',
      );
      final file = File(path.join(directory.path, 'cognote.sqlite'));
      try {
        _createLegacyDatabase(file, sourceVersion);
        await _openAndVerifyV3(file, sourceVersion);
        await _openAndVerifyV3(file, sourceVersion);
      } finally {
        await _deleteDirectoryWhenReleased(directory);
      }
    });
  }

  test(
    'v2 to v3 failure rolls back FTS schema and preserves observations',
    () async {
      final directory = await Directory.systemTemp.createTemp(
        'cng107_failed_v2_',
      );
      final file = File(path.join(directory.path, 'cognote.sqlite'));
      try {
        _createLegacyDatabase(file, 2);
        final database = CognoteDatabase(
          NativeDatabase(
            file,
            setup: (rawDatabase) {
              rawDatabase.execute('''
              CREATE TRIGGER fail_fts_backfill
              BEFORE INSERT ON observation_search_fts
              BEGIN
                SELECT RAISE(ABORT, 'forced backfill failure');
              END
            ''');
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

        final raw = sqlite.sqlite3.open(file.path);
        try {
          expect(raw.userVersion, 2);
          expect(
            raw
                .select(
                  "SELECT raw_text FROM observations WHERE id = 'legacy-observation'",
                )
                .single['raw_text'],
            '蓝雪花 AI 观察',
          );
          expect(
            raw.select(
              "SELECT name FROM sqlite_master WHERE name LIKE 'observation_search_fts%'",
            ),
            isEmpty,
          );
        } finally {
          raw.close();
        }
      } finally {
        await _deleteDirectoryWhenReleased(directory);
      }
    },
  );

  test(
    'v1 to v3 FTS-stage failure rolls back v2 tables and remains recoverable',
    () async {
      final directory = await Directory.systemTemp.createTemp(
        'cng107_failed_v1_',
      );
      final file = File(path.join(directory.path, 'cognote.sqlite'));
      try {
        _createLegacyDatabase(file, 1);
        final database = CognoteDatabase(
          NativeDatabase(file),
          beforeFtsMigration: () async =>
              throw StateError('forced FTS migration failure'),
        );
        try {
          await expectLater(
            database.customSelect('SELECT 1').getSingle(),
            throwsA(anything),
          );
        } finally {
          await database.close();
        }

        final raw = sqlite.sqlite3.open(file.path);
        try {
          expect(raw.userVersion, 1);
          expect(
            raw.select("SELECT id FROM principals WHERE id = 'legacy-owner'"),
            hasLength(1),
          );
          expect(
            raw.select(
              "SELECT name FROM sqlite_master WHERE name IN ('observations', 'local_assets') OR name LIKE 'observation_search_fts%'",
            ),
            isEmpty,
          );
        } finally {
          raw.close();
        }

        await _openAndVerifyV3(file, 1);
      } finally {
        await _deleteDirectoryWhenReleased(directory);
      }
    },
  );
}

Future<void> _openAndVerifyV3(File file, int sourceVersion) async {
  final database = CognoteDatabase(NativeDatabase(file));
  try {
    final version = await database
        .customSelect('PRAGMA user_version')
        .getSingle();
    expect(version.read<int>('user_version'), 4);
    final principal = await database
        .customSelect("SELECT id FROM principals WHERE id = 'legacy-owner'")
        .getSingle();
    expect(principal.read<String>('id'), 'legacy-owner');

    final observations = await database
        .customSelect('SELECT id, raw_text FROM observations ORDER BY id')
        .get();
    if (sourceVersion == 1) {
      expect(observations, isEmpty);
    } else {
      expect(observations, hasLength(2));
      final indexed = await database
          .customSelect(
            "SELECT observation_id, raw_text FROM observation_search_fts ORDER BY observation_id",
          )
          .get();
      expect(indexed, hasLength(1));
      expect(
        indexed.single.read<String>('observation_id'),
        'legacy-observation',
      );
      expect(indexed.single.read<String>('raw_text'), '蓝雪花 AI 观察');
    }
  } finally {
    await database.close();
  }
}

void _createLegacyDatabase(File file, int version) {
  final raw = sqlite.sqlite3.open(file.path);
  try {
    raw.execute('PRAGMA foreign_keys = ON');
    raw.execute('''
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
    raw.execute('''
      CREATE TABLE device_identities (
        id TEXT NOT NULL PRIMARY KEY,
        principal_id TEXT NOT NULL UNIQUE REFERENCES principals(id) ON DELETE RESTRICT,
        public_install_id TEXT NOT NULL UNIQUE,
        created_at INTEGER NOT NULL,
        last_seen_at INTEGER NOT NULL
      )
    ''');
    raw.execute(
      "INSERT INTO principals VALUES ('legacy-owner', 'anonymous', 'active', 'cn-mainland', 'cn', 1, NULL)",
    );
    raw.execute(
      "INSERT INTO device_identities VALUES ('legacy-device', 'legacy-owner', 'legacy-install', 1, 1)",
    );
    if (version >= 2) {
      raw.execute('''
        CREATE TABLE observations (
          id TEXT NOT NULL PRIMARY KEY,
          owner_id TEXT NOT NULL REFERENCES principals(id) ON DELETE RESTRICT,
          input_type TEXT NOT NULL,
          raw_text TEXT,
          captured_at INTEGER NOT NULL,
          timezone_offset INTEGER NOT NULL,
          privacy_level TEXT NOT NULL,
          cloud_ai_policy TEXT NOT NULL,
          sync_policy TEXT NOT NULL,
          created_by_device_id TEXT NOT NULL REFERENCES device_identities(id) ON DELETE RESTRICT,
          created_at INTEGER NOT NULL,
          updated_at INTEGER NOT NULL,
          deleted_at INTEGER,
          server_revision INTEGER
        )
      ''');
      raw.execute('''
        CREATE TABLE local_assets (
          id TEXT NOT NULL PRIMARY KEY,
          observation_id TEXT NOT NULL REFERENCES observations(id) ON DELETE RESTRICT,
          local_uri TEXT NOT NULL,
          analysis_derivative_uri TEXT,
          local_original_present INTEGER NOT NULL,
          mime_type TEXT NOT NULL,
          bytes INTEGER NOT NULL,
          width INTEGER,
          height INTEGER,
          sha256 TEXT NOT NULL,
          exif_removed INTEGER NOT NULL,
          upload_state TEXT NOT NULL,
          created_at INTEGER NOT NULL,
          updated_at INTEGER NOT NULL
        )
      ''');
      raw.execute('''
        INSERT INTO observations VALUES
          ('legacy-observation', 'legacy-owner', 'text', '蓝雪花 AI 观察', 10, 480,
           'normal', 'local_only', 'local_only', 'legacy-device', 10, 10, NULL, NULL),
          ('legacy-null', 'legacy-owner', 'image', NULL, 9, 480,
           'normal', 'local_only', 'local_only', 'legacy-device', 9, 9, NULL, NULL)
      ''');
    }
    raw.userVersion = version;
  } finally {
    raw.close();
  }
}

Future<void> _deleteDirectoryWhenReleased(Directory directory) async {
  for (var attempt = 0; attempt < 10; attempt++) {
    try {
      await directory.delete(recursive: true);
      return;
    } on PathAccessException {
      if (attempt == 9) rethrow;
      await Future<void>.delayed(const Duration(milliseconds: 50));
    }
  }
}
