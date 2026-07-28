import 'package:cognote/src/database/cognote_database.dart';
import 'package:drift/drift.dart' show Variable;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late CognoteDatabase database;

  setUp(() {
    database = CognoteDatabase(NativeDatabase.memory());
  });

  tearDown(() async {
    await database.close();
  });

  test('new database has schema version 3 and observations table', () async {
    final version = await database
        .customSelect('PRAGMA user_version')
        .getSingle();
    final tables = await database
        .customSelect(
          "SELECT name FROM sqlite_master WHERE type = 'table' AND name = ?",
          variables: [const Variable<String>('observations')],
        )
        .get();

    expect(version.read<int>('user_version'), 4);
    expect(tables, hasLength(1));
  });

  test('valid observation accepts null raw text', () async {
    await _insertIdentity(database);

    await _insertObservation(database);

    final row = await database
        .customSelect(
          'SELECT * FROM observations WHERE id = ?',
          variables: [const Variable<String>('observation-1')],
        )
        .getSingle();
    expect(row.readNullable<String>('raw_text'), isNull);
    expect(row.read<int>('timezone_offset'), 480);
  });

  test('observation rejects a missing owner', () async {
    await _insertIdentity(database);

    await expectLater(
      _insertObservation(database, ownerId: 'missing-owner'),
      throwsA(isA<SqliteException>()),
    );
    await _expectNoObservations(database);
  });

  test('observation rejects a missing creator device', () async {
    await _insertIdentity(database);

    await expectLater(
      _insertObservation(database, deviceId: 'missing-device'),
      throwsA(isA<SqliteException>()),
    );
    await _expectNoObservations(database);
  });

  test('observation input type only accepts image and text', () async {
    await _insertIdentity(database);

    for (final inputType in ['text', 'image']) {
      await _insertObservation(
        database,
        id: 'observation-$inputType',
        inputType: inputType,
      );
    }
    await expectLater(
      _insertObservation(
        database,
        id: 'observation-invalid',
        inputType: 'audio',
      ),
      throwsA(isA<SqliteException>()),
    );
  });

  test('normal is the only privacy level accepted by this database', () async {
    await _insertIdentity(database);

    await _insertObservation(database);
    for (final privacyLevel in ['private_local', 'unknown', '']) {
      await expectLater(
        _insertObservation(
          database,
          id: 'observation-${privacyLevel.isEmpty ? 'empty' : privacyLevel}',
          privacyLevel: privacyLevel,
        ),
        throwsA(isA<SqliteException>()),
      );
    }
  });

  test(
    'timezone offset accepts boundaries and rejects out-of-range values',
    () async {
      await _insertIdentity(database);

      await _insertObservation(
        database,
        id: 'observation-min-offset',
        timezoneOffset: -840,
      );
      await _insertObservation(
        database,
        id: 'observation-max-offset',
        timezoneOffset: 840,
      );
      for (final offset in [-841, 841]) {
        await expectLater(
          _insertObservation(
            database,
            id: 'observation-offset-$offset',
            timezoneOffset: offset,
          ),
          throwsA(isA<SqliteException>()),
        );
      }
    },
  );

  test('cloud AI policy accepts every frozen value', () async {
    await _insertIdentity(database);

    for (final policy in ['local_only', 'consent_required', 'allowed']) {
      await _insertObservation(
        database,
        id: 'observation-cloud-$policy',
        cloudAiPolicy: policy,
      );
    }
  });

  test('cloud AI policy rejects runtime states and empty values', () async {
    await _insertIdentity(database);

    for (final policy in ['uploaded', '']) {
      await expectLater(
        _insertObservation(
          database,
          id: 'observation-cloud-${policy.isEmpty ? 'empty' : policy}',
          cloudAiPolicy: policy,
        ),
        throwsA(isA<SqliteException>()),
      );
    }
  });

  test('sync policy accepts every frozen value', () async {
    await _insertIdentity(database);

    for (final policy in ['local_only', 'sync_enabled']) {
      await _insertObservation(
        database,
        id: 'observation-sync-$policy',
        syncPolicy: policy,
      );
    }
  });

  test('sync policy rejects runtime states and empty values', () async {
    await _insertIdentity(database);

    for (final policy in ['synced', '']) {
      await expectLater(
        _insertObservation(
          database,
          id: 'observation-sync-${policy.isEmpty ? 'empty' : policy}',
          syncPolicy: policy,
        ),
        throwsA(isA<SqliteException>()),
      );
    }
  });

  test('valid local assets support one-to-many observations', () async {
    await _insertIdentity(database);
    await _insertObservation(database);

    await _insertLocalAsset(database, id: 'asset-1');
    await _insertLocalAsset(
      database,
      id: 'asset-2',
      localUri: 'file:///asset-2.jpg',
      sha256: 'hash-2',
    );

    final count = await database
        .customSelect('SELECT COUNT(*) AS count FROM local_assets')
        .getSingle();
    expect(count.read<int>('count'), 2);
  });

  test('local asset rejects a missing observation', () async {
    await _insertIdentity(database);

    await expectLater(
      _insertLocalAsset(database, observationId: 'missing-observation'),
      throwsA(isA<SqliteException>()),
    );
    await _expectNoLocalAssets(database);
  });

  test('local asset bytes must be positive', () async {
    await _insertIdentity(database);
    await _insertObservation(database);

    for (final bytes in [0, -1]) {
      await expectLater(
        _insertLocalAsset(database, id: 'asset-bytes-$bytes', bytes: bytes),
        throwsA(isA<SqliteException>()),
      );
    }
    await _expectNoLocalAssets(database);
  });

  test('local asset dimensions must be both null or both positive', () async {
    await _insertIdentity(database);
    await _insertObservation(database);

    await _insertLocalAsset(database, id: 'asset-null-dimensions');
    await _insertLocalAsset(
      database,
      id: 'asset-positive-dimensions',
      localUri: 'file:///positive.jpg',
      sha256: 'positive-hash',
      width: 1920,
      height: 1080,
    );
    for (final dimensions in [
      (width: 100, height: null),
      (width: null, height: 100),
      (width: 0, height: 100),
      (width: 100, height: 0),
      (width: -1, height: 100),
      (width: 100, height: -1),
    ]) {
      await expectLater(
        _insertLocalAsset(
          database,
          id: 'asset-invalid-${dimensions.width}-${dimensions.height}',
          localUri: 'file:///invalid-${dimensions.width}-${dimensions.height}',
          sha256: 'invalid-${dimensions.width}-${dimensions.height}',
          width: dimensions.width,
          height: dimensions.height,
        ),
        throwsA(isA<SqliteException>()),
      );
    }
  });

  test('upload state accepts every frozen value', () async {
    await _insertIdentity(database);
    await _insertObservation(database);

    for (final state in [
      'local_only',
      'upload_queued',
      'uploading',
      'uploaded',
      'failed_retryable',
      'failed_terminal',
      'blocked_by_policy',
    ]) {
      await _insertLocalAsset(
        database,
        id: 'asset-$state',
        localUri: 'file:///$state.jpg',
        sha256: 'hash-$state',
        uploadState: state,
      );
    }
  });

  test('upload state rejects unknown and empty values', () async {
    await _insertIdentity(database);
    await _insertObservation(database);

    for (final state in ['synced', '']) {
      await expectLater(
        _insertLocalAsset(
          database,
          id: 'asset-${state.isEmpty ? 'empty' : state}',
          uploadState: state,
        ),
        throwsA(isA<SqliteException>()),
      );
    }
  });

  test('physical observation deletion cascades local asset metadata', () async {
    await _insertIdentity(database);
    await _insertObservation(database);
    await _insertLocalAsset(database);

    await database.customStatement('DELETE FROM observations WHERE id = ?', [
      'observation-1',
    ]);

    await _expectNoLocalAssets(database);
  });
}

Future<void> _insertIdentity(CognoteDatabase database) async {
  final now = DateTime.utc(2026, 7, 26).millisecondsSinceEpoch;
  await database.customStatement(
    'INSERT INTO principals '
    '(id, kind, status, home_region, data_residency, created_at) '
    "VALUES ('principal-1', 'anonymous', 'active', 'cn-mainland', 'cn', ?)",
    [now],
  );
  await database.customStatement(
    'INSERT INTO device_identities '
    '(id, principal_id, public_install_id, created_at, last_seen_at) '
    "VALUES ('device-1', 'principal-1', 'install-1', ?, ?)",
    [now, now],
  );
}

Future<void> _insertObservation(
  CognoteDatabase database, {
  String id = 'observation-1',
  String ownerId = 'principal-1',
  String inputType = 'text',
  String? rawText,
  int timezoneOffset = 480,
  String privacyLevel = 'normal',
  String cloudAiPolicy = 'local_only',
  String syncPolicy = 'local_only',
  String deviceId = 'device-1',
}) async {
  final now = DateTime.utc(2026, 7, 26).millisecondsSinceEpoch;
  await database.customStatement(
    'INSERT INTO observations '
    '(id, owner_id, input_type, raw_text, captured_at, timezone_offset, '
    'privacy_level, cloud_ai_policy, sync_policy, created_by_device_id, '
    'created_at, updated_at) '
    'VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)',
    [
      id,
      ownerId,
      inputType,
      rawText,
      now,
      timezoneOffset,
      privacyLevel,
      cloudAiPolicy,
      syncPolicy,
      deviceId,
      now,
      now,
    ],
  );
}

Future<void> _expectNoObservations(CognoteDatabase database) async {
  final count = await database
      .customSelect('SELECT COUNT(*) AS count FROM observations')
      .getSingle();
  expect(count.read<int>('count'), 0);
}

Future<void> _insertLocalAsset(
  CognoteDatabase database, {
  String id = 'asset-1',
  String observationId = 'observation-1',
  String localUri = 'file:///asset-1.jpg',
  String? analysisDerivativeUri,
  bool localOriginalPresent = true,
  String mimeType = 'image/jpeg',
  int bytes = 1024,
  int? width,
  int? height,
  String sha256 = 'hash-1',
  bool exifRemoved = true,
  String uploadState = 'local_only',
}) async {
  final now = DateTime.utc(2026, 7, 26).millisecondsSinceEpoch;
  await database.customStatement(
    'INSERT INTO local_assets '
    '(id, observation_id, local_uri, analysis_derivative_uri, '
    'local_original_present, mime_type, bytes, width, height, sha256, '
    'exif_removed, upload_state, created_at, updated_at) '
    'VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)',
    [
      id,
      observationId,
      localUri,
      analysisDerivativeUri,
      localOriginalPresent ? 1 : 0,
      mimeType,
      bytes,
      width,
      height,
      sha256,
      exifRemoved ? 1 : 0,
      uploadState,
      now,
      now,
    ],
  );
}

Future<void> _expectNoLocalAssets(CognoteDatabase database) async {
  final count = await database
      .customSelect('SELECT COUNT(*) AS count FROM local_assets')
      .getSingle();
  expect(count.read<int>('count'), 0);
}
