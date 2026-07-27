import 'package:cognote/src/database/cognote_database.dart' hide Observation;
import 'package:cognote/src/identity/application/initialize_local_identity.dart';
import 'package:cognote/src/identity/data/drift_identity_repository.dart';
import 'package:cognote/src/observation/data/drift_observation_repository.dart';
import 'package:cognote/src/observation/domain/observation.dart';
import 'package:cognote/src/observation/domain/observation_mutation_outcome.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'deleted timeline filters, orders, and reacts to delete and restore',
    () async {
      final database = CognoteDatabase(NativeDatabase.memory());
      addTearDown(database.close);
      final identity = await InitializeLocalIdentity(
        DriftIdentityRepository(database),
      )();
      final repository = DriftObservationRepository(database);
      final ownerId = identity.principal.id;
      final deviceId = identity.device.id;
      await _insertOtherIdentity(database);
      await repository.create(_observation(_id1, ownerId, deviceId));
      await repository.create(_observation(_id2, ownerId, deviceId));
      await repository.create(_observation(_id3, ownerId, deviceId));
      await repository.create(
        _observation(_id4, 'other-owner', 'other-device'),
      );

      final emissions = <List<Observation>>[];
      final subscription = repository
          .watchDeletedTimeline(ownerId: ownerId)
          .listen(emissions.add);
      addTearDown(subscription.cancel);
      await _waitFor(() => emissions.length == 1);

      final firstDeletedAt = DateTime.utc(2026, 7, 28, 1);
      expect(
        await repository.deleteObservation(
          ownerId: ownerId,
          observationId: _id1,
          deletedAt: firstDeletedAt,
        ),
        ObservationMutationOutcome.changed,
      );
      await _waitFor(() => emissions.length == 2);

      final latestDeletedAt = firstDeletedAt.add(const Duration(hours: 1));
      await repository.deleteObservation(
        ownerId: ownerId,
        observationId: _id2,
        deletedAt: latestDeletedAt,
      );
      await repository.deleteObservation(
        ownerId: ownerId,
        observationId: _id3,
        deletedAt: latestDeletedAt,
      );
      await repository.deleteObservation(
        ownerId: 'other-owner',
        observationId: _id4,
        deletedAt: latestDeletedAt.add(const Duration(hours: 1)),
      );
      await _waitFor(() => emissions.last.length == 3);

      expect(emissions.first, isEmpty);
      expect(emissions[1].map((item) => item.id), [_id1]);
      expect(emissions.last.map((item) => item.id), [_id3, _id2, _id1]);
      expect(emissions.last.every((item) => item.ownerId == ownerId), isTrue);

      await repository.restoreObservation(
        ownerId: ownerId,
        observationId: _id3,
        restoredAt: DateTime.utc(2026, 7, 28, 4),
      );
      await _waitFor(() => emissions.last.length == 2);
      expect(emissions.last.map((item) => item.id), [_id2, _id1]);
    },
  );

  test('closed database propagates deleted timeline failure', () async {
    final database = CognoteDatabase(NativeDatabase.memory());
    final identity = await InitializeLocalIdentity(
      DriftIdentityRepository(database),
    )();
    final repository = DriftObservationRepository(database);
    await database.close();

    await expectLater(
      repository.watchDeletedTimeline(ownerId: identity.principal.id).first,
      throwsA(anything),
    );
  });
}

Observation _observation(String id, String ownerId, String deviceId) {
  final createdAt = DateTime.utc(2026, 7, 26, 11);
  return Observation(
    id: id,
    ownerId: ownerId,
    inputType: ObservationInputType.text,
    rawText: id,
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
