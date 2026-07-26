import 'package:cognote/src/database/cognote_database.dart'
    hide LocalAsset, Observation;
import 'package:cognote/src/identity/application/initialize_local_identity.dart';
import 'package:cognote/src/identity/data/drift_identity_repository.dart';
import 'package:cognote/src/observation/data/drift_observation_repository.dart';
import 'package:cognote/src/observation/domain/image_observation_exceptions.dart';
import 'package:cognote/src/observation/domain/local_asset.dart';
import 'package:cognote/src/observation/domain/observation.dart';
import 'package:cognote/src/observation/domain/observation_exceptions.dart';
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
    'creates and reads Observation plus LocalAsset in one transaction',
    () async {
      final aggregate = _aggregate(ownerId: ownerId, deviceId: deviceId);
      final result = await repository.createImage(aggregate);
      expect(result.observation.inputType, ObservationInputType.image);
      expect(result.observation.rawText, ' caption ');
      expect(result.localAsset.localUri, 'originals/01/asset.jpg');
      expect(result.localAsset.analysisDerivativeUri, isNull);
      expect(result.localAsset.localOriginalPresent, isTrue);
      expect(result.localAsset.exifRemoved, isFalse);
      expect(result.localAsset.uploadState, 'local_only');
      expect(await database.select(database.observations).get(), hasLength(1));
      expect(await database.select(database.localAssets).get(), hasLength(1));
      expect(
        await repository.isLocalUriReferenced('originals/01/asset.jpg'),
        isTrue,
      );
    },
  );

  test(
    'local asset failure rolls back observation and propagates database error',
    () async {
      final invalid = _aggregate(
        ownerId: ownerId,
        deviceId: deviceId,
        bytes: 0,
      );
      await expectLater(
        repository.createImage(invalid),
        throwsA(isA<SqliteException>()),
      );
      expect(await database.select(database.observations).get(), isEmpty);
      expect(await database.select(database.localAssets).get(), isEmpty);
    },
  );

  test('observation failure leaves no local asset', () async {
    final invalid = _aggregate(ownerId: 'missing', deviceId: deviceId);
    await expectLater(
      repository.createImage(invalid),
      throwsA(isA<SqliteException>()),
    );
    expect(await database.select(database.localAssets).get(), isEmpty);
  });

  test(
    'identical retry returns original aggregate without updating time',
    () async {
      final first = await repository.createImage(
        _aggregate(ownerId: ownerId, deviceId: deviceId),
      );
      final retry = await repository.createImage(
        _aggregate(
          ownerId: ownerId,
          deviceId: deviceId,
          createdAt: _now.add(const Duration(hours: 1)),
        ),
      );
      expect(retry.observation.createdAt, first.observation.createdAt);
      expect(retry.localAsset.createdAt, first.localAsset.createdAt);
      expect(await database.select(database.localAssets).get(), hasLength(1));
    },
  );

  test('same observation id with different semantics conflicts', () async {
    await repository.createImage(
      _aggregate(ownerId: ownerId, deviceId: deviceId),
    );
    await expectLater(
      repository.createImage(
        _aggregate(ownerId: ownerId, deviceId: deviceId, caption: 'different'),
      ),
      throwsA(isA<ObservationIdConflictException>()),
    );
  });

  test('same local asset id with different semantics conflicts', () async {
    final originalTime = _now;
    await repository.createImage(
      _aggregate(ownerId: ownerId, deviceId: deviceId, createdAt: originalTime),
    );
    await expectLater(
      repository.createImage(
        _aggregate(
          ownerId: ownerId,
          deviceId: deviceId,
          observationId: _observationId2,
          localUri: 'originals/01/other.jpg',
        ),
      ),
      throwsA(isA<LocalAssetIdConflictException>()),
    );
    final observations = await database.select(database.observations).get();
    final assets = await database.select(database.localAssets).get();
    expect(observations, hasLength(1));
    expect(observations.single.id, _observationId);
    expect(observations.single.createdAt.toUtc(), originalTime);
    expect(observations.single.updatedAt.toUtc(), originalTime);
    expect(assets, hasLength(1));
    expect(assets.single.id, _assetId);
    expect(assets.single.observationId, _observationId);
    expect(assets.single.localUri, 'originals/01/asset.jpg');
    expect(assets.single.createdAt.toUtc(), originalTime);
    expect(assets.single.updatedAt.toUtc(), originalTime);
    expect(observations.where((row) => row.id == _observationId2), isEmpty);
  });

  test('different ids may store the same SHA-256', () async {
    await repository.createImage(
      _aggregate(ownerId: ownerId, deviceId: deviceId),
    );
    await repository.createImage(
      _aggregate(
        ownerId: ownerId,
        deviceId: deviceId,
        observationId: _observationId2,
        assetId: _assetId2,
        localUri: 'originals/01/second.jpg',
      ),
    );
    expect(await database.select(database.observations).get(), hasLength(2));
  });
}

ImageObservationAggregate _aggregate({
  required String ownerId,
  required String deviceId,
  String observationId = _observationId,
  String assetId = _assetId,
  String caption = ' caption ',
  String localUri = 'originals/01/asset.jpg',
  int bytes = 123,
  DateTime? createdAt,
}) {
  final time = createdAt ?? _now;
  return ImageObservationAggregate(
    observation: Observation(
      id: observationId,
      ownerId: ownerId,
      inputType: ObservationInputType.image,
      rawText: caption,
      capturedAt: _captured,
      timezoneOffset: 480,
      privacyLevel: PrivacyLevel.normal,
      cloudAiPolicy: CloudAiPolicy.localOnly,
      syncPolicy: SyncPolicy.localOnly,
      createdByDeviceId: deviceId,
      createdAt: time,
      updatedAt: time,
      deletedAt: null,
      serverRevision: null,
    ),
    localAsset: LocalAsset(
      id: assetId,
      observationId: observationId,
      localUri: localUri,
      analysisDerivativeUri: null,
      localOriginalPresent: true,
      mimeType: 'image/jpeg',
      bytes: bytes,
      width: 10,
      height: 20,
      sha256: 'abc',
      exifRemoved: false,
      uploadState: 'local_only',
      createdAt: time,
      updatedAt: time,
    ),
  );
}

const _observationId = '018f7777-7777-7777-8777-777777777777';
const _observationId2 = '018f7777-7777-7777-8777-777777777778';
const _assetId = '018f8888-8888-7888-8888-888888888888';
const _assetId2 = '018f8888-8888-7888-8888-888888888889';
final _now = DateTime.utc(2026, 7, 26);
final _captured = DateTime.utc(2026, 7, 25);
