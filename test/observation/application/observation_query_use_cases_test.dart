import 'package:cognote/src/identity/domain/device_identity.dart';
import 'package:cognote/src/identity/domain/identity_repository.dart';
import 'package:cognote/src/identity/domain/principal.dart';
import 'package:cognote/src/observation/application/get_observation_detail.dart';
import 'package:cognote/src/observation/application/watch_observation_timeline.dart';

import 'package:cognote/src/observation/domain/observation.dart';
import 'package:cognote/src/observation/domain/observation_detail.dart';
import 'package:cognote/src/observation/domain/observation_mutation_outcome.dart';
import 'package:cognote/src/observation/domain/observation_query_repository.dart';
import 'package:cognote/src/observation/domain/observation_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('timeline use case always binds the current principal id', () async {
    final repository = _RecordingRepository();
    final useCase = WatchObservationTimeline(
      repository: repository,
      localIdentity: _identity,
    );

    expect(await useCase().first, isEmpty);
    expect(repository.timelineOwnerId, 'current-owner');
  });

  test(
    'detail use case always binds current principal and requested id',
    () async {
      final repository = _RecordingRepository();
      final useCase = GetObservationDetail(
        repository: repository,
        localIdentity: _identity,
      );

      expect(await useCase('observation-id'), isNull);
      expect(repository.detailOwnerId, 'current-owner');
      expect(repository.detailObservationId, 'observation-id');
    },
  );
}

class _RecordingRepository
    implements ObservationRepository, ObservationQueryRepository {
  String? timelineOwnerId;
  String? detailOwnerId;
  String? detailObservationId;

  @override
  Stream<List<Observation>> watchActiveTimeline({required String ownerId}) {
    timelineOwnerId = ownerId;
    return Stream.value(const []);
  }

  @override
  Stream<List<Observation>> watchDeletedTimeline({required String ownerId}) =>
      Stream.value(const []);

  @override
  Future<ObservationDetail?> findActiveDetail({
    required String ownerId,
    required String observationId,
  }) async {
    detailOwnerId = ownerId;
    detailObservationId = observationId;
    return null;
  }

  @override
  Future<Observation> create(Observation observation) =>
      throw UnimplementedError();

  @override
  Future<ImageObservationAggregate> createImage(
    ImageObservationAggregate aggregate,
  ) => throw UnimplementedError();

  @override
  Future<ImageObservationAggregate?> findImageByObservationId(String id) =>
      throw UnimplementedError();

  @override
  Future<bool> isLocalUriReferenced(String localUri) =>
      throw UnimplementedError();

  @override
  Future<ObservationMutationOutcome> deleteObservation({
    required String ownerId,
    required String observationId,
    required DateTime deletedAt,
  }) => throw UnimplementedError();

  @override
  Future<ObservationMutationOutcome> restoreObservation({
    required String ownerId,
    required String observationId,
    required DateTime restoredAt,
  }) => throw UnimplementedError();
}

final _identity = LocalIdentity(
  principal: Principal(
    id: 'current-owner',
    kind: PrincipalKind.anonymous,
    status: PrincipalStatus.active,
    homeRegion: 'cn-mainland',
    dataResidency: 'cn',
    createdAt: DateTime.utc(2026, 7, 26),
    upgradedAt: null,
  ),
  device: DeviceIdentity(
    id: 'current-device',
    principalId: 'current-owner',
    publicInstallId: 'install',
    createdAt: DateTime.utc(2026, 7, 26),
    lastSeenAt: DateTime.utc(2026, 7, 26),
  ),
);
