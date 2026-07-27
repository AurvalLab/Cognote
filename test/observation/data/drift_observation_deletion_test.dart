import 'package:cognote/src/database/cognote_database.dart'
    hide LocalAsset, Observation;
import 'package:cognote/src/identity/application/initialize_local_identity.dart';
import 'package:cognote/src/identity/data/drift_identity_repository.dart';
import 'package:cognote/src/observation/data/drift_observation_repository.dart';
import 'package:cognote/src/observation/domain/local_asset.dart';
import 'package:cognote/src/observation/domain/observation.dart';
import 'package:cognote/src/observation/domain/observation_mutation_outcome.dart';
import 'package:cognote/src/observation/domain/observation_repository.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late CognoteDatabase database;
  late DriftObservationRepository repository;
  late String ownerId;
  late String deviceId;

  setUp(() async {
    database = CognoteDatabase(NativeDatabase.memory());
    final identity = await InitializeLocalIdentity(
      DriftIdentityRepository(database),
    )();
    ownerId = identity.principal.id;
    deviceId = identity.device.id;
    repository = DriftObservationRepository(database);
  });

  tearDown(() => database.close());

  test(
    'first delete updates only tombstone timestamps and keeps asset',
    () async {
      final original = _observation(ownerId: ownerId, deviceId: deviceId);
      await repository.createImage(
        ImageObservationAggregate(
          observation: original,
          localAsset: _asset(original.id),
        ),
      );
      final deletedAt = DateTime.utc(2026, 7, 28, 1);

      final outcome = await repository.deleteObservation(
        ownerId: ownerId,
        observationId: original.id,
        deletedAt: deletedAt,
      );
      final row = await (database.select(
        database.observations,
      )..where((table) => table.id.equals(original.id))).getSingle();

      expect(outcome, ObservationMutationOutcome.changed);
      expect(row.deletedAt?.toUtc(), deletedAt);
      expect(row.updatedAt.toUtc(), deletedAt);
      expect(row.capturedAt.toUtc(), original.capturedAt);
      expect(row.createdAt.toUtc(), original.createdAt);
      expect(row.rawText, original.rawText);
      expect(await database.select(database.localAssets).get(), hasLength(1));
    },
  );

  test('repeated delete is unchanged and preserves first timestamps', () async {
    final original = _observation(ownerId: ownerId, deviceId: deviceId);
    await repository.create(original);
    final firstTime = DateTime.utc(2026, 7, 28, 1);
    await repository.deleteObservation(
      ownerId: ownerId,
      observationId: original.id,
      deletedAt: firstTime,
    );

    final outcome = await repository.deleteObservation(
      ownerId: ownerId,
      observationId: original.id,
      deletedAt: firstTime.add(const Duration(hours: 1)),
    );
    final row = await database.select(database.observations).getSingle();

    expect(outcome, ObservationMutationOutcome.unchanged);
    expect(row.deletedAt?.toUtc(), firstTime);
    expect(row.updatedAt.toUtc(), firstTime);
  });

  test('concurrent deletes change the tombstone only once', () async {
    final original = _observation(ownerId: ownerId, deviceId: deviceId);
    await repository.create(original);
    final firstTime = DateTime.utc(2026, 7, 28, 1);
    final secondTime = firstTime.add(const Duration(hours: 1));

    final outcomes = await Future.wait([
      repository.deleteObservation(
        ownerId: ownerId,
        observationId: original.id,
        deletedAt: firstTime,
      ),
      repository.deleteObservation(
        ownerId: ownerId,
        observationId: original.id,
        deletedAt: secondTime,
      ),
    ]);
    final row = await database.select(database.observations).getSingle();

    expect(
      outcomes,
      containsAll([
        ObservationMutationOutcome.changed,
        ObservationMutationOutcome.unchanged,
      ]),
    );
    expect(row.updatedAt.toUtc(), row.deletedAt?.toUtc());
    expect(row.deletedAt?.toUtc(), anyOf(firstTime, secondTime));
  });

  test('delete hides missing and foreign observations as not found', () async {
    await _insertOtherIdentity(database);
    await repository.create(
      _observation(ownerId: 'other-owner', deviceId: 'other-device'),
    );

    expect(
      await repository.deleteObservation(
        ownerId: ownerId,
        observationId: 'missing',
        deletedAt: DateTime.utc(2026, 7, 28),
      ),
      ObservationMutationOutcome.notFound,
    );
    expect(
      await repository.deleteObservation(
        ownerId: ownerId,
        observationId: _id,
        deletedAt: DateTime.utc(2026, 7, 28),
      ),
      ObservationMutationOutcome.notFound,
    );
    expect(
      (await database.select(database.observations).getSingle()).deletedAt,
      isNull,
    );
  });

  test('first restore clears tombstone and updates only updatedAt', () async {
    final original = _observation(ownerId: ownerId, deviceId: deviceId);
    await repository.createImage(
      ImageObservationAggregate(
        observation: original,
        localAsset: _asset(original.id),
      ),
    );
    await repository.deleteObservation(
      ownerId: ownerId,
      observationId: original.id,
      deletedAt: DateTime.utc(2026, 7, 28, 1),
    );
    final restoredAt = DateTime.utc(2026, 7, 28, 2);

    final outcome = await repository.restoreObservation(
      ownerId: ownerId,
      observationId: original.id,
      restoredAt: restoredAt,
    );
    final row = await database.select(database.observations).getSingle();

    expect(outcome, ObservationMutationOutcome.changed);
    expect(row.deletedAt, isNull);
    expect(row.updatedAt.toUtc(), restoredAt);
    expect(row.capturedAt.toUtc(), original.capturedAt);
    expect(row.createdAt.toUtc(), original.createdAt);
    expect(row.rawText, original.rawText);
    expect(await database.select(database.localAssets).get(), hasLength(1));
  });

  test(
    'repeated restore is unchanged and does not modify timestamps',
    () async {
      final original = _observation(ownerId: ownerId, deviceId: deviceId);
      await repository.create(original);

      final outcome = await repository.restoreObservation(
        ownerId: ownerId,
        observationId: original.id,
        restoredAt: DateTime.utc(2026, 7, 28),
      );
      final row = await database.select(database.observations).getSingle();

      expect(outcome, ObservationMutationOutcome.unchanged);
      expect(row.deletedAt, isNull);
      expect(row.updatedAt.toUtc(), original.updatedAt);
    },
  );

  test('concurrent restores clear the tombstone only once', () async {
    final original = _observation(ownerId: ownerId, deviceId: deviceId);
    await repository.create(original);
    await repository.deleteObservation(
      ownerId: ownerId,
      observationId: original.id,
      deletedAt: DateTime.utc(2026, 7, 28, 1),
    );
    final firstTime = DateTime.utc(2026, 7, 28, 2);
    final secondTime = firstTime.add(const Duration(hours: 1));

    final outcomes = await Future.wait([
      repository.restoreObservation(
        ownerId: ownerId,
        observationId: original.id,
        restoredAt: firstTime,
      ),
      repository.restoreObservation(
        ownerId: ownerId,
        observationId: original.id,
        restoredAt: secondTime,
      ),
    ]);
    final row = await database.select(database.observations).getSingle();

    expect(
      outcomes.where(
        (outcome) => outcome == ObservationMutationOutcome.changed,
      ),
      hasLength(1),
    );
    expect(
      outcomes.where(
        (outcome) => outcome == ObservationMutationOutcome.unchanged,
      ),
      hasLength(1),
    );
    expect(
      outcomes.where(
        (outcome) => outcome == ObservationMutationOutcome.notFound,
      ),
      isEmpty,
    );
    expect(row.deletedAt, isNull);
    expect(row.updatedAt.toUtc(), anyOf(firstTime, secondTime));
  });

  test('restore hides missing and foreign observations as not found', () async {
    await _insertOtherIdentity(database);
    await repository.create(
      _observation(ownerId: 'other-owner', deviceId: 'other-device'),
    );
    await repository.deleteObservation(
      ownerId: 'other-owner',
      observationId: _id,
      deletedAt: DateTime.utc(2026, 7, 28),
    );

    expect(
      await repository.restoreObservation(
        ownerId: ownerId,
        observationId: 'missing',
        restoredAt: DateTime.utc(2026, 7, 29),
      ),
      ObservationMutationOutcome.notFound,
    );
    expect(
      await repository.restoreObservation(
        ownerId: ownerId,
        observationId: _id,
        restoredAt: DateTime.utc(2026, 7, 29),
      ),
      ObservationMutationOutcome.notFound,
    );
    expect(
      (await database.select(database.observations).getSingle()).deletedAt,
      isNotNull,
    );
  });
}

Observation _observation({required String ownerId, required String deviceId}) {
  final createdAt = DateTime.utc(2026, 7, 26, 11);
  return Observation(
    id: _id,
    ownerId: ownerId,
    inputType: ObservationInputType.image,
    rawText: '图片说明',
    capturedAt: DateTime.utc(2026, 7, 26, 10),
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

LocalAsset _asset(String observationId) => LocalAsset(
  id: _assetId,
  observationId: observationId,
  localUri: 'originals/01/asset.jpg',
  analysisDerivativeUri: null,
  localOriginalPresent: true,
  mimeType: 'image/jpeg',
  bytes: 123,
  width: 10,
  height: 20,
  sha256: 'abc',
  exifRemoved: false,
  uploadState: 'local_only',
  createdAt: DateTime.utc(2026, 7, 26, 11),
  updatedAt: DateTime.utc(2026, 7, 26, 11),
);

Future<void> _insertOtherIdentity(CognoteDatabase database) async {
  final now = DateTime.utc(2026, 7, 26).millisecondsSinceEpoch;
  await database.customStatement(
    "INSERT INTO principals (id, kind, status, home_region, data_residency, created_at) VALUES ('other-owner', 'account', 'active', 'cn-mainland', 'cn', ?)",
    [now],
  );
  await database.customStatement(
    "INSERT INTO device_identities (id, principal_id, public_install_id, created_at, last_seen_at) VALUES ('other-device', 'other-owner', 'other-install', ?, ?)",
    [now, now],
  );
}

const _id = '018f1111-1111-7111-8111-111111111111';
const _assetId = '018faaaa-aaaa-7aaa-8aaa-aaaaaaaaaaaa';
