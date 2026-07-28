import 'dart:io';

import 'package:cognote/src/database/cognote_database.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as path;
import 'package:sqlite3/sqlite3.dart' as sqlite;

void main() {
  for (final sourceVersion in [1, 2, 3]) {
    test('real v$sourceVersion database migrates to v4 and reopens', () async {
      final directory = await Directory.systemTemp.createTemp(
        'cng108_v${sourceVersion}_to_v4_',
      );
      final file = File(path.join(directory.path, 'cognote.sqlite'));
      try {
        _createLegacyDatabase(file, sourceVersion);
        await _openAndVerifyV4(file, sourceVersion);
        await _openAndVerifyV4(file, sourceVersion);
      } finally {
        await _deleteDirectoryWhenReleased(directory);
      }
    });
  }

  test('v3 to v4 outbox-stage failure is atomic and recoverable', () async {
    final directory = await Directory.systemTemp.createTemp(
      'cng108_failed_v3_',
    );
    final file = File(path.join(directory.path, 'cognote.sqlite'));
    try {
      _createLegacyDatabase(file, 3);
      await _expectOutboxMigrationFailure(file);
      _expectPreV4State(file, 3);
      await _openAndVerifyV4(file, 3);
    } finally {
      await _deleteDirectoryWhenReleased(directory);
    }
  });

  test(
    'v1 to v4 outbox-stage failure rolls back prior migration stages',
    () async {
      final directory = await Directory.systemTemp.createTemp(
        'cng108_failed_v1_',
      );
      final file = File(path.join(directory.path, 'cognote.sqlite'));
      try {
        _createLegacyDatabase(file, 1);
        await _expectOutboxMigrationFailure(file);
        _expectPreV4State(file, 1);
        await _openAndVerifyV4(file, 1);
      } finally {
        await _deleteDirectoryWhenReleased(directory);
      }
    },
  );
}

Future<void> _expectOutboxMigrationFailure(File file) async {
  final database = CognoteDatabase(
    NativeDatabase(file),
    beforeOutboxMigration: () async =>
        throw StateError('forced outbox migration failure'),
  );
  try {
    await expectLater(
      database.customSelect('SELECT 1').getSingle(),
      throwsA(anything),
    );
  } finally {
    await database.close();
  }
}

void _expectPreV4State(File file, int expectedVersion) {
  final raw = sqlite.sqlite3.open(file.path);
  try {
    expect(raw.userVersion, expectedVersion);
    expect(
      raw.select("SELECT id FROM principals WHERE id = 'legacy-owner'"),
      hasLength(1),
    );
    expect(
      raw.select("SELECT id FROM device_identities WHERE id = 'legacy-device'"),
      hasLength(1),
    );
    expect(
      raw.select(
        "SELECT name FROM sqlite_master WHERE name = 'outbox_operations'",
      ),
      isEmpty,
    );
    expect(
      raw.select(
        "SELECT name FROM sqlite_master WHERE name = 'outbox_operations_owner_created_operation'",
      ),
      isEmpty,
    );
    if (expectedVersion == 1) {
      expect(
        raw.select('''
          SELECT name FROM sqlite_master
          WHERE name IN ('observations', 'local_assets', 'observation_search_fts')
          OR name LIKE 'observation_search_fts_%'
        '''),
        isEmpty,
      );
      return;
    }

    expect(raw.select('SELECT id FROM observations ORDER BY id'), hasLength(2));
    expect(
      raw.select("SELECT id FROM local_assets WHERE id = 'legacy-asset'"),
      hasLength(1),
    );
    if (expectedVersion == 3) {
      expect(
        raw.select(
          "SELECT observation_id, raw_text FROM observation_search_fts WHERE observation_id = 'legacy-text'",
        ),
        hasLength(1),
      );
    }
  } finally {
    raw.close();
  }
}

Future<void> _openAndVerifyV4(File file, int sourceVersion) async {
  final database = CognoteDatabase(NativeDatabase(file));
  try {
    final version = await database
        .customSelect('PRAGMA user_version')
        .getSingle();
    expect(version.read<int>('user_version'), 4);
    final outboxCount = await database
        .customSelect('SELECT COUNT(*) AS count FROM outbox_operations')
        .getSingle();
    expect(outboxCount.read<int>('count'), 0);
    if (sourceVersion == 1) {
      final observationCount = await database
          .customSelect('SELECT COUNT(*) AS count FROM observations')
          .getSingle();
      expect(observationCount.read<int>('count'), 0);
      return;
    }

    final observations = await database
        .customSelect('SELECT id, deleted_at FROM observations ORDER BY id')
        .get();
    expect(observations.map((row) => row.read<String>('id')), [
      'legacy-image',
      'legacy-text',
    ]);
    expect(observations.first.readNullable<DateTime>('deleted_at'), isNotNull);
    expect(
      await database.customSelect('SELECT id FROM local_assets').get(),
      hasLength(1),
    );
    final fts = await database
        .customSelect('SELECT observation_id FROM observation_search_fts')
        .get();
    expect(fts.map((row) => row.read<String>('observation_id')), [
      'legacy-text',
    ]);
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
      raw.execute(_observationsSql);
      raw.execute(_localAssetsSql);
      raw.execute('''
        INSERT INTO observations VALUES
          ('legacy-text', 'legacy-owner', 'text', '蓝雪花 AI 观察', 10, 480,
           'normal', 'local_only', 'local_only', 'legacy-device', 10, 10, NULL, NULL),
          ('legacy-image', 'legacy-owner', 'image', NULL, 9, 480,
           'normal', 'local_only', 'local_only', 'legacy-device', 9, 11, 12, NULL)
      ''');
      raw.execute('''
        INSERT INTO local_assets VALUES
          ('legacy-asset', 'legacy-image', 'assets/legacy.jpg', NULL, 1,
           'image/jpeg', 99, 3, 3, 'hash', 1, 'local_only', 9, 11)
      ''');
    }
    if (version >= 3) {
      raw.execute('''
        CREATE VIRTUAL TABLE observation_search_fts USING fts5(
          observation_id UNINDEXED, raw_text, tokenize = 'trigram case_sensitive 0'
        )
      ''');
      raw.execute(
        "INSERT INTO observation_search_fts VALUES ('legacy-text', '蓝雪花 AI 观察')",
      );
    }
    raw.userVersion = version;
  } finally {
    raw.close();
  }
}

const _observationsSql = '''
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
''';

const _localAssetsSql = '''
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
''';

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
