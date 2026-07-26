import 'dart:io';

import 'package:cognote/src/database/cognote_database.dart' hide Observation;
import 'package:cognote/src/identity/application/initialize_local_identity.dart';
import 'package:cognote/src/identity/data/drift_identity_repository.dart';
import 'package:cognote/src/observation/application/create_text_observation.dart';
import 'package:cognote/src/observation/data/drift_observation_repository.dart';
import 'package:cognote/src/observation/domain/observation.dart';
import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as path;

void main() {
  const id = '018f8888-8888-7888-8888-888888888888';
  final capturedAt = DateTime.utc(2020, 1, 2, 3, 4);
  final createdAt = DateTime.utc(2026, 7, 26, 10, 30);

  test('creates a text observation and returns persisted fields', () async {
    final database = CognoteDatabase(NativeDatabase.memory());
    addTearDown(database.close);
    final identity = await InitializeLocalIdentity(
      DriftIdentityRepository(database),
    )();
    final repository = DriftObservationRepository(database);
    final observation = _observation(
      id: id,
      ownerId: identity.principal.id,
      deviceId: identity.device.id,
      capturedAt: capturedAt,
      createdAt: createdAt,
    );

    final result = await repository.create(observation);

    expect(result.id, id);
    expect(result.rawText, '  第一行\n第二行  ');
    expect(result.inputType, ObservationInputType.text);
    expect(result.capturedAt, capturedAt);
    expect(result.createdAt, createdAt);
    expect(result.updatedAt, createdAt);
    expect(await database.select(database.observations).get(), hasLength(1));
  });

  test('persists the observation after closing and reopening SQLite', () async {
    final directory = await Directory.systemTemp.createTemp('cognote_cng103_');
    final file = File(path.join(directory.path, 'cognote.sqlite'));
    try {
      final first = CognoteDatabase(NativeDatabase(file));
      final identity = await InitializeLocalIdentity(
        DriftIdentityRepository(first),
      )();
      await DriftObservationRepository(first).create(
        _observation(
          id: id,
          ownerId: identity.principal.id,
          deviceId: identity.device.id,
          capturedAt: capturedAt,
          createdAt: createdAt,
        ),
      );
      await first.close();

      final second = CognoteDatabase(NativeDatabase(file));
      try {
        final rows = await second.select(second.observations).get();
        expect(rows, hasLength(1));
        expect(rows.single.id, id);
        expect(rows.single.rawText, '  第一行\n第二行  ');
      } finally {
        await second.close();
      }
    } finally {
      await directory.delete(recursive: true);
    }
  });

  test('allows identical text under different ids', () async {
    final database = CognoteDatabase(NativeDatabase.memory());
    addTearDown(database.close);
    final identity = await InitializeLocalIdentity(
      DriftIdentityRepository(database),
    )();
    final repository = DriftObservationRepository(database);

    await repository.create(
      _observation(
        id: id,
        ownerId: identity.principal.id,
        deviceId: identity.device.id,
        capturedAt: capturedAt,
        createdAt: createdAt,
      ),
    );
    await repository.create(
      _observation(
        id: '018f8888-8888-7888-8888-888888888889',
        ownerId: identity.principal.id,
        deviceId: identity.device.id,
        capturedAt: capturedAt,
        createdAt: createdAt,
      ),
    );

    expect(await database.select(database.observations).get(), hasLength(2));
  });

  test('propagates a foreign key failure and leaves no observation', () async {
    final database = CognoteDatabase(NativeDatabase.memory());
    addTearDown(database.close);
    final repository = DriftObservationRepository(database);

    await expectLater(
      repository.create(
        _observation(
          id: id,
          ownerId: 'missing-owner',
          deviceId: 'missing-device',
          capturedAt: capturedAt,
          createdAt: createdAt,
        ),
      ),
      throwsA(isA<SqliteException>()),
    );
    expect(await database.select(database.observations).get(), isEmpty);
  });

  test('repeated identical creation returns the original timestamps', () async {
    final database = CognoteDatabase(NativeDatabase.memory());
    addTearDown(database.close);
    final identity = await InitializeLocalIdentity(
      DriftIdentityRepository(database),
    )();
    final repository = DriftObservationRepository(database);
    final original = _observation(
      id: id,
      ownerId: identity.principal.id,
      deviceId: identity.device.id,
      capturedAt: capturedAt,
      createdAt: createdAt,
    );
    final retry = _copyObservation(
      original,
      createdAt: createdAt.add(const Duration(minutes: 5)),
    );

    final first = await repository.create(original);
    final second = await repository.create(retry);

    expect(await database.select(database.observations).get(), hasLength(1));
    expect(second.id, first.id);
    expect(second.createdAt, first.createdAt);
    expect(second.updatedAt, first.updatedAt);
  });

  test('same id with different creation semantics throws conflict', () async {
    final database = CognoteDatabase(NativeDatabase.memory());
    addTearDown(database.close);
    final identity = await InitializeLocalIdentity(
      DriftIdentityRepository(database),
    )();
    final repository = DriftObservationRepository(database);
    final original = _observation(
      id: id,
      ownerId: identity.principal.id,
      deviceId: identity.device.id,
      capturedAt: capturedAt,
      createdAt: createdAt,
    );
    await repository.create(original);

    for (final conflicting in [
      _copyObservation(original, rawText: 'different'),
      _copyObservation(
        original,
        capturedAt: capturedAt.add(const Duration(days: 1)),
      ),
      _copyObservation(original, timezoneOffset: 60),
    ]) {
      await expectLater(
        repository.create(conflicting),
        throwsA(isA<ObservationIdConflictException>()),
      );
    }
    expect(await database.select(database.observations).get(), hasLength(1));
  });

  test('same id for a deleted observation throws conflict', () async {
    final database = CognoteDatabase(NativeDatabase.memory());
    addTearDown(database.close);
    final identity = await InitializeLocalIdentity(
      DriftIdentityRepository(database),
    )();
    final repository = DriftObservationRepository(database);
    final original = _observation(
      id: id,
      ownerId: identity.principal.id,
      deviceId: identity.device.id,
      capturedAt: capturedAt,
      createdAt: createdAt,
    );
    await repository.create(original);
    await (database.update(
      database.observations,
    )..where((table) => table.id.equals(id))).write(
      ObservationsCompanion(deletedAt: Value(DateTime.utc(2026, 7, 27))),
    );

    await expectLater(
      repository.create(original),
      throwsA(isA<ObservationIdConflictException>()),
    );
  });

  test('concurrent identical creation converges on one observation', () async {
    final database = CognoteDatabase(NativeDatabase.memory());
    addTearDown(database.close);
    final identity = await InitializeLocalIdentity(
      DriftIdentityRepository(database),
    )();
    final repository = DriftObservationRepository(database);
    final original = _observation(
      id: id,
      ownerId: identity.principal.id,
      deviceId: identity.device.id,
      capturedAt: capturedAt,
      createdAt: createdAt,
    );

    final results = await Future.wait([
      repository.create(original),
      repository.create(original),
    ]);

    expect(results.map((item) => item.id).toSet(), {id});
    expect(await database.select(database.observations).get(), hasLength(1));
  });

  test(
    'non-primary-key constraint failures are propagated unchanged',
    () async {
      final database = CognoteDatabase(NativeDatabase.memory());
      addTearDown(database.close);
      final identity = await InitializeLocalIdentity(
        DriftIdentityRepository(database),
      )();
      final repository = DriftObservationRepository(database);
      final invalid = _copyObservation(
        _observation(
          id: id,
          ownerId: identity.principal.id,
          deviceId: identity.device.id,
          capturedAt: capturedAt,
          createdAt: createdAt,
        ),
        timezoneOffset: 841,
      );

      await expectLater(
        repository.create(invalid),
        throwsA(isA<SqliteException>()),
      );
    },
  );
}

Observation _observation({
  required String id,
  required String ownerId,
  required String deviceId,
  required DateTime capturedAt,
  required DateTime createdAt,
}) {
  return Observation(
    id: id,
    ownerId: ownerId,
    inputType: ObservationInputType.text,
    rawText: '  第一行\n第二行  ',
    capturedAt: capturedAt,
    timezoneOffset: 480,
    privacyLevel: PrivacyLevel.normal,
    cloudAiPolicy: CloudAiPolicy.localOnly,
    syncPolicy: SyncPolicy.localOnly,
    createdByDeviceId: deviceId,
    createdAt: createdAt,
    updatedAt: createdAt,
    deletedAt: null,
    serverRevision: null,
  );
}

Observation _copyObservation(
  Observation source, {
  String? rawText,
  DateTime? capturedAt,
  int? timezoneOffset,
  DateTime? createdAt,
}) {
  final creationTime = createdAt ?? source.createdAt;
  return Observation(
    id: source.id,
    ownerId: source.ownerId,
    inputType: source.inputType,
    rawText: rawText ?? source.rawText,
    capturedAt: capturedAt ?? source.capturedAt,
    timezoneOffset: timezoneOffset ?? source.timezoneOffset,
    privacyLevel: source.privacyLevel,
    cloudAiPolicy: source.cloudAiPolicy,
    syncPolicy: source.syncPolicy,
    createdByDeviceId: source.createdByDeviceId,
    createdAt: creationTime,
    updatedAt: creationTime,
    deletedAt: source.deletedAt,
    serverRevision: source.serverRevision,
  );
}
