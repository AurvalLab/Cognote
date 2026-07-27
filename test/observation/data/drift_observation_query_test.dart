import 'package:cognote/src/database/cognote_database.dart'
    hide LocalAsset, Observation;
import 'package:cognote/src/identity/application/initialize_local_identity.dart';
import 'package:cognote/src/identity/data/drift_identity_repository.dart';
import 'package:cognote/src/observation/data/drift_observation_repository.dart';
import 'package:cognote/src/observation/domain/image_observation_exceptions.dart';
import 'package:cognote/src/observation/domain/local_asset.dart';
import 'package:cognote/src/observation/domain/observation.dart';
import 'package:cognote/src/observation/domain/observation_repository.dart';
import 'package:drift/drift.dart' show Value;
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

  test('timeline is empty before observations exist', () async {
    expect(
      await repository.watchActiveTimeline(ownerId: ownerId).first,
      isEmpty,
    );
  });

  test(
    'timeline filters owner and tombstones and uses stable ordering',
    () async {
      await _insertOtherIdentity(database);
      final captured = DateTime.utc(2026, 7, 26, 10);
      final olderCaptured = captured.subtract(const Duration(hours: 1));
      await repository.create(
        _observation(
          id: _id1,
          ownerId: ownerId,
          deviceId: deviceId,
          capturedAt: olderCaptured,
          createdAt: captured,
        ),
      );
      await repository.create(
        _observation(
          id: _id2,
          ownerId: ownerId,
          deviceId: deviceId,
          capturedAt: captured,
          createdAt: captured.subtract(const Duration(minutes: 1)),
          inputType: ObservationInputType.image,
          rawText: '图片',
        ),
      );
      await repository.create(
        _observation(
          id: _id3,
          ownerId: ownerId,
          deviceId: deviceId,
          capturedAt: captured,
          createdAt: captured,
        ),
      );
      await repository.create(
        _observation(
          id: _id4,
          ownerId: ownerId,
          deviceId: deviceId,
          capturedAt: captured,
          createdAt: captured,
        ),
      );
      await repository.create(
        _observation(
          id: _id5,
          ownerId: 'other-owner',
          deviceId: 'other-device',
          capturedAt: captured.add(const Duration(days: 1)),
          createdAt: captured,
        ),
      );
      await (database.update(database.observations)
            ..where((table) => table.id.equals(_id3)))
          .write(ObservationsCompanion(deletedAt: Value(captured)));

      final result = await repository
          .watchActiveTimeline(ownerId: ownerId)
          .first;

      expect(result.map((item) => item.id), [_id4, _id2, _id1]);
      expect(
        result.map((item) => item.inputType),
        containsAll(ObservationInputType.values),
      );
    },
  );

  test('timeline emits after text and image transaction commits', () async {
    final emissions = repository.watchActiveTimeline(ownerId: ownerId);
    final values = <List<Observation>>[];
    final subscription = emissions.listen(values.add);
    addTearDown(subscription.cancel);
    await _waitFor(() => values.length == 1);

    await repository.create(
      _observation(id: _id1, ownerId: ownerId, deviceId: deviceId),
    );
    await _waitFor(() => values.length == 2);

    await repository.createImage(
      ImageObservationAggregate(
        observation: _observation(
          id: _id2,
          ownerId: ownerId,
          deviceId: deviceId,
          capturedAt: DateTime.utc(2026, 7, 27),
          inputType: ObservationInputType.image,
          rawText: '图片',
        ),
        localAsset: _asset(_id2),
      ),
    );
    await _waitFor(() => values.length == 3);

    expect(values[0], isEmpty);
    expect(values[1].map((item) => item.id), [_id1]);
    expect(values[2].map((item) => item.id), [_id2, _id1]);
    expect(
      await repository.findActiveDetail(ownerId: ownerId, observationId: _id2),
      isNotNull,
    );
  });

  test('finds text and image details without updating timestamps', () async {
    final text = _observation(id: _id1, ownerId: ownerId, deviceId: deviceId);
    final image = _observation(
      id: _id2,
      ownerId: ownerId,
      deviceId: deviceId,
      inputType: ObservationInputType.image,
      rawText: '图片说明',
    );
    await repository.create(text);
    await repository.createImage(
      ImageObservationAggregate(observation: image, localAsset: _asset(_id2)),
    );

    final textDetail = await repository.findActiveDetail(
      ownerId: ownerId,
      observationId: _id1,
    );
    final imageDetail = await repository.findActiveDetail(
      ownerId: ownerId,
      observationId: _id2,
    );

    expect(textDetail!.observation.rawText, '文字');
    expect(textDetail.localAsset, isNull);
    expect(textDetail.observation.updatedAt, text.updatedAt);
    expect(imageDetail!.observation.rawText, '图片说明');
    expect(imageDetail.localAsset!.localUri, 'originals/01/asset.jpg');
    expect(imageDetail.observation.updatedAt, image.updatedAt);
  });

  test('detail hides missing, foreign, and deleted observations', () async {
    await _insertOtherIdentity(database);
    await repository.create(
      _observation(id: _id1, ownerId: ownerId, deviceId: deviceId),
    );
    await repository.create(
      _observation(id: _id2, ownerId: 'other-owner', deviceId: 'other-device'),
    );
    await (database.update(
      database.observations,
    )..where((table) => table.id.equals(_id1))).write(
      ObservationsCompanion(deletedAt: Value(DateTime.utc(2026, 7, 27))),
    );

    expect(
      await repository.findActiveDetail(
        ownerId: ownerId,
        observationId: 'missing',
      ),
      isNull,
    );
    expect(
      await repository.findActiveDetail(ownerId: ownerId, observationId: _id2),
      isNull,
    );
    expect(
      await repository.findActiveDetail(ownerId: ownerId, observationId: _id1),
      isNull,
    );
  });

  test('image detail without local asset reports integrity failure', () async {
    await repository.create(
      _observation(
        id: _id1,
        ownerId: ownerId,
        deviceId: deviceId,
        inputType: ObservationInputType.image,
      ),
    );

    await expectLater(
      repository.findActiveDetail(ownerId: ownerId, observationId: _id1),
      throwsA(isA<AssetIntegrityException>()),
    );
  });

  test('closed database propagates timeline query failure', () async {
    await database.close();
    await expectLater(
      repository.watchActiveTimeline(ownerId: ownerId).first,
      throwsA(anything),
    );
  });
}

Observation _observation({
  required String id,
  required String ownerId,
  required String deviceId,
  DateTime? capturedAt,
  DateTime? createdAt,
  ObservationInputType inputType = ObservationInputType.text,
  String? rawText = '文字',
}) {
  final created = createdAt ?? DateTime.utc(2026, 7, 26, 11);
  return Observation(
    id: id,
    ownerId: ownerId,
    inputType: inputType,
    rawText: rawText,
    capturedAt: capturedAt ?? DateTime.utc(2026, 7, 26, 10),
    timezoneOffset: 480,
    privacyLevel: PrivacyLevel.normal,
    cloudAiPolicy: CloudAiPolicy.localOnly,
    syncPolicy: SyncPolicy.localOnly,
    createdByDeviceId: deviceId,
    createdAt: created,
    updatedAt: created,
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

Future<void> _waitFor(bool Function() condition) async {
  for (var attempt = 0; attempt < 100; attempt++) {
    if (condition()) return;
    await Future<void>.delayed(const Duration(milliseconds: 10));
  }
  fail('Timed out waiting for stream emission');
}

const _id1 = '018f1111-1111-7111-8111-111111111111';
const _id2 = '018f2222-2222-7222-8222-222222222222';
const _id3 = '018f3333-3333-7333-8333-333333333333';
const _id4 = '018f4444-4444-7444-8444-444444444444';
const _id5 = '018f5555-5555-7555-8555-555555555555';
const _assetId = '018faaaa-aaaa-7aaa-8aaa-aaaaaaaaaaaa';
