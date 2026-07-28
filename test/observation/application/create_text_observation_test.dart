import 'package:cognote/src/identity/domain/device_identity.dart';
import 'package:cognote/src/identity/domain/identity_repository.dart';
import 'package:cognote/src/identity/domain/principal.dart';
import 'package:cognote/src/observation/application/create_text_observation.dart';
import 'package:cognote/src/observation/data/uuid_v7_observation_id_generator.dart';
import 'package:cognote/src/observation/domain/observation.dart';
import 'package:cognote/src/observation/domain/observation_id_generator.dart';
import 'package:cognote/src/observation/domain/observation_mutation_outcome.dart';
import 'package:cognote/src/observation/domain/observation_outbox_mutation_repository.dart';
import 'package:cognote/src/observation/domain/observation_repository.dart';
import 'package:cognote/src/outbox/domain/outbox_operation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:uuid/uuid.dart';

void main() {
  final now = DateTime.utc(2026, 7, 26, 10, 30);

  group('prepare', () {
    test('production generator creates a valid UUIDv7', () {
      final id = const UuidV7ObservationIdGenerator().generate();

      expect(Uuid.isValidUUID(fromString: id), isTrue);
      expect(id.split('-')[2].startsWith('7'), isTrue);
    });

    test('uses an injected stable id and UTC clock', () {
      final useCase = _useCase(now: now, id: _fixedId);

      final command = useCase.prepare(rawText: 'text', timezoneOffset: 480);

      expect(command.observationId, _fixedId);
      expect(command.capturedAtUtc, now);
    });

    test('preserves an explicit historical UTC captured time', () {
      final useCase = _useCase(now: now);
      final capturedAt = DateTime.utc(2020, 1, 2, 3, 4);

      final command = useCase.prepare(
        rawText: 'history',
        timezoneOffset: -300,
        capturedAtUtc: capturedAt,
      );

      expect(command.capturedAtUtc, capturedAt);
    });

    test('rejects a non-UTC captured time', () {
      final useCase = _useCase(now: now);
      final localTime = DateTime(2020, 1, 2, 3, 4);

      expect(
        () => useCase.prepare(
          rawText: 'text',
          timezoneOffset: 480,
          capturedAtUtc: localTime,
        ),
        throwsA(isA<InvalidCapturedAtException>()),
      );
    });

    test('accepts timezone offset boundaries', () {
      final useCase = _useCase(now: now);

      expect(
        useCase.prepare(rawText: 'min', timezoneOffset: -840).timezoneOffset,
        -840,
      );
      expect(
        useCase.prepare(rawText: 'max', timezoneOffset: 840).timezoneOffset,
        840,
      );
    });

    test('rejects timezone offsets outside the valid range', () {
      final useCase = _useCase(now: now);

      for (final offset in [-841, 841]) {
        expect(
          () => useCase.prepare(rawText: 'text', timezoneOffset: offset),
          throwsA(isA<InvalidTimezoneOffsetException>()),
        );
      }
    });

    test('rejects empty and whitespace-only text', () {
      final useCase = _useCase(now: now);

      for (final rawText in ['', '   ', '\n\t\n']) {
        expect(
          () => useCase.prepare(rawText: rawText, timezoneOffset: 480),
          throwsA(isA<InvalidObservationTextException>()),
        );
      }
    });

    test('preserves spaces, newlines, and Unicode exactly', () {
      final useCase = _useCase(now: now);
      const rawText = '  第一行\nＳｅｃｏｎｄ  ';

      final command = useCase.prepare(rawText: rawText, timezoneOffset: 480);

      expect(command.rawText, rawText);
    });
  });

  group('execute', () {
    test(
      'maps identity and frozen creation fields to a domain model',
      () async {
        final repository = _RecordingRepository();
        final useCase = CreateTextObservation(
          repository: repository,
          outboxMutationRepository: repository,
          localIdentity: _identity(),
          idGenerator: const _FixedIdGenerator(_fixedId),
          utcNow: () => now,
        );
        final command = useCase.prepare(
          rawText: '  原文\n保留  ',
          timezoneOffset: 480,
          capturedAtUtc: DateTime.utc(2020, 1, 2),
        );

        final result = await useCase.execute(command);

        expect(result, same(repository.created));
        expect(result.id, _fixedId);
        expect(result.ownerId, 'principal-1');
        expect(result.createdByDeviceId, 'device-1');
        expect(result.inputType, ObservationInputType.text);
        expect(result.rawText, '  原文\n保留  ');
        expect(result.capturedAt, DateTime.utc(2020, 1, 2));
        expect(result.timezoneOffset, 480);
        expect(result.privacyLevel, PrivacyLevel.normal);
        expect(result.cloudAiPolicy, CloudAiPolicy.localOnly);
        expect(result.syncPolicy, SyncPolicy.localOnly);
        expect(result.createdAt, now);
        expect(result.updatedAt, now);
        expect(result.deletedAt, isNull);
        expect(result.serverRevision, isNull);
        expect(repository.operation?.operationId, command.operationId);
        expect(repository.operation?.ownerId, 'principal-1');
        expect(repository.operation?.deviceId, 'device-1');
        expect(repository.operation?.aggregateId, result.id);
        expect(repository.operation?.operationKind, 'observation_upsert');
        expect(repository.operation?.createdAt, command.createdAt);

        await useCase.execute(command);
        expect(repository.operations, hasLength(2));
        expect(repository.operations.last.operationId, command.operationId);
        expect(repository.operations.last.createdAt, command.createdAt);
      },
    );

    test('defensively rejects a malformed or non-v7 observation id', () async {
      final useCase = _useCase(now: now);

      for (final id in [
        '',
        'not-a-uuid',
        '550e8400-e29b-41d4-a716-446655440000',
      ]) {
        final command = CreateTextObservationCommand(
          observationId: id,
          rawText: 'text',
          capturedAtUtc: now,
          createdAt: now,
          timezoneOffset: 480,
        );
        await expectLater(
          () => useCase.execute(command),
          throwsA(isA<InvalidObservationIdException>()),
        );
      }
    });

    test('propagates repository errors unchanged', () async {
      final error = StateError('database failed');
      final failingRepository = _FailingRepository(error);
      final useCase = CreateTextObservation(
        repository: failingRepository,
        outboxMutationRepository: failingRepository,
        localIdentity: _identity(),
        idGenerator: const _FixedIdGenerator(_fixedId),
        utcNow: () => now,
      );
      final command = useCase.prepare(rawText: 'text', timezoneOffset: 480);

      await expectLater(useCase.execute(command), throwsA(same(error)));
    });
  });
}

const _fixedId = '018f7777-7777-7777-8777-777777777777';

CreateTextObservation _useCase({required DateTime now, String id = _fixedId}) {
  return CreateTextObservation(
    repository: _UnusedRepository(),
    localIdentity: _identity(),
    idGenerator: _FixedIdGenerator(id),
    utcNow: () => now,
  );
}

LocalIdentity _identity() {
  final createdAt = DateTime.utc(2026, 7, 25);
  const principalId = 'principal-1';
  return LocalIdentity(
    principal: Principal(
      id: principalId,
      kind: PrincipalKind.anonymous,
      status: PrincipalStatus.active,
      homeRegion: 'cn-mainland',
      dataResidency: 'cn',
      createdAt: createdAt,
      upgradedAt: null,
    ),
    device: DeviceIdentity(
      id: 'device-1',
      principalId: principalId,
      publicInstallId: 'install-1',
      createdAt: createdAt,
      lastSeenAt: createdAt,
    ),
  );
}

class _FixedIdGenerator implements ObservationIdGenerator {
  const _FixedIdGenerator(this.id);

  final String id;

  @override
  String generate() => id;
}

class _UnusedRepository implements ObservationRepository {
  @override
  Future<Observation> create(Observation observation) =>
      throw UnimplementedError();

  @override
  Future<ImageObservationAggregate> createImage(
    ImageObservationAggregate aggregate,
  ) => throw UnimplementedError();

  @override
  Future<ObservationMutationOutcome> deleteObservation({
    required String ownerId,
    required String observationId,
    required DateTime deletedAt,
  }) => throw UnimplementedError();

  @override
  Future<ImageObservationAggregate?> findImageByObservationId(String id) =>
      throw UnimplementedError();

  @override
  Future<bool> isLocalUriReferenced(String localUri) =>
      throw UnimplementedError();

  @override
  Future<ObservationMutationOutcome> restoreObservation({
    required String ownerId,
    required String observationId,
    required DateTime restoredAt,
  }) => throw UnimplementedError();
}

class _RecordingRepository extends _UnusedRepository
    implements ObservationOutboxMutationRepository {
  Observation? created;
  OutboxOperation? operation;
  final operations = <OutboxOperation>[];

  @override
  Future<Observation> createTextWithOutbox({
    required Observation observation,
    required OutboxOperation operation,
  }) async {
    created = observation;
    this.operation = operation;
    operations.add(operation);
    return observation;
  }

  @override
  Future<ImageObservationAggregate> createImageWithOutbox({
    required ImageObservationAggregate aggregate,
    required OutboxOperation operation,
  }) => throw UnimplementedError();

  @override
  Future<ObservationMutationOutcome> deleteWithOutbox({
    required String ownerId,
    required String observationId,
    required DateTime deletedAt,
    required OutboxOperation operation,
  }) => throw UnimplementedError();

  @override
  Future<ObservationMutationOutcome> restoreWithOutbox({
    required String ownerId,
    required String observationId,
    required DateTime restoredAt,
    required OutboxOperation operation,
  }) => throw UnimplementedError();
}

class _FailingRepository extends _UnusedRepository
    implements ObservationOutboxMutationRepository {
  _FailingRepository(this.error);

  final Object error;

  @override
  Future<Observation> createTextWithOutbox({
    required Observation observation,
    required OutboxOperation operation,
  }) => Future.error(error);

  @override
  Future<ImageObservationAggregate> createImageWithOutbox({
    required ImageObservationAggregate aggregate,
    required OutboxOperation operation,
  }) => throw UnimplementedError();

  @override
  Future<ObservationMutationOutcome> deleteWithOutbox({
    required String ownerId,
    required String observationId,
    required DateTime deletedAt,
    required OutboxOperation operation,
  }) => throw UnimplementedError();

  @override
  Future<ObservationMutationOutcome> restoreWithOutbox({
    required String ownerId,
    required String observationId,
    required DateTime restoredAt,
    required OutboxOperation operation,
  }) => throw UnimplementedError();
}
