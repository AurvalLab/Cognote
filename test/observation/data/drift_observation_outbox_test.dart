import 'package:cognote/src/database/cognote_database.dart'
    hide LocalAsset, Observation;
import 'package:cognote/src/identity/application/initialize_local_identity.dart';
import 'package:cognote/src/identity/data/drift_identity_repository.dart';
import 'package:cognote/src/observation/data/drift_observation_repository.dart';
import 'package:cognote/src/observation/domain/local_asset.dart';
import 'package:cognote/src/observation/domain/observation.dart';
import 'package:cognote/src/observation/domain/observation_mutation_outcome.dart';
import 'package:cognote/src/observation/domain/observation_repository.dart';
import 'package:cognote/src/outbox/domain/outbox_operation.dart';
import 'package:cognote/src/outbox/domain/outbox_operation_conflict_exception.dart';
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

  test('text operation inserts once and replays idempotently', () async {
    final observation = _textObservation(ownerId, deviceId);
    final operation = _operation(
      operationId: _operationId,
      ownerId: ownerId,
      deviceId: deviceId,
      aggregateId: observation.id,
      kind: 'observation_upsert',
      createdAt: observation.createdAt,
    );

    await repository.createTextWithOutbox(
      observation: observation,
      operation: operation,
    );
    await repository.createTextWithOutbox(
      observation: observation,
      operation: operation,
    );

    expect(await database.select(database.observations).get(), hasLength(1));
    final outbox = await database.select(database.outboxOperations).get();
    expect(outbox, hasLength(1));
    expect(outbox.single.operationKind, 'observation_upsert');
  });

  test(
    'text operation accepts timestamps finer than SQLite precision',
    () async {
      final createdAt = _time.add(
        const Duration(milliseconds: 654, microseconds: 321),
      );
      final observation = _textObservation(
        ownerId,
        deviceId,
        createdAt: createdAt,
      );
      final operation = _operation(
        operationId: _operationId,
        ownerId: ownerId,
        deviceId: deviceId,
        aggregateId: observation.id,
        kind: 'observation_upsert',
        createdAt: createdAt,
      );

      await repository.createTextWithOutbox(
        observation: observation,
        operation: operation,
      );
      await repository.createTextWithOutbox(
        observation: observation,
        operation: operation,
      );

      final stored = await database
          .select(database.outboxOperations)
          .getSingle();
      expect(
        stored.createdAt.millisecondsSinceEpoch ~/
            Duration.millisecondsPerSecond,
        createdAt.millisecondsSinceEpoch ~/ Duration.millisecondsPerSecond,
      );
    },
  );

  test(
    'same operation id with different aggregate rolls back text insert',
    () async {
      final first = _textObservation(ownerId, deviceId);
      final operation = _operation(
        operationId: _operationId,
        ownerId: ownerId,
        deviceId: deviceId,
        aggregateId: first.id,
        kind: 'observation_upsert',
        createdAt: first.createdAt,
      );
      await repository.createTextWithOutbox(
        observation: first,
        operation: operation,
      );

      final second = _textObservation(ownerId, deviceId, id: _observationId2);
      await expectLater(
        repository.createTextWithOutbox(
          observation: second,
          operation: _operation(
            operationId: _operationId,
            ownerId: ownerId,
            deviceId: deviceId,
            aggregateId: second.id,
            kind: 'observation_upsert',
            createdAt: second.createdAt,
          ),
        ),
        throwsA(isA<OutboxOperationConflictException>()),
      );
      expect(await database.select(database.observations).get(), hasLength(1));
      expect(
        await database.select(database.outboxOperations).get(),
        hasLength(1),
      );
    },
  );

  test(
    'same operation id conflicts on owner device kind and created at',
    () async {
      final observation = _textObservation(ownerId, deviceId);
      final operation = _operation(
        operationId: _operationId,
        ownerId: ownerId,
        deviceId: deviceId,
        aggregateId: observation.id,
        kind: 'observation_upsert',
        createdAt: observation.createdAt,
      );
      await repository.createTextWithOutbox(
        observation: observation,
        operation: operation,
      );

      for (final conflict in [
        _operation(
          operationId: _operationId,
          ownerId: 'other-owner',
          deviceId: deviceId,
          aggregateId: observation.id,
          kind: 'observation_upsert',
          createdAt: observation.createdAt,
        ),
        _operation(
          operationId: _operationId,
          ownerId: ownerId,
          deviceId: 'other-device',
          aggregateId: observation.id,
          kind: 'observation_upsert',
          createdAt: observation.createdAt,
        ),
        _operation(
          operationId: _operationId,
          ownerId: ownerId,
          deviceId: deviceId,
          aggregateId: observation.id,
          kind: 'observation_delete',
          createdAt: observation.createdAt,
        ),
        _operation(
          operationId: _operationId,
          ownerId: ownerId,
          deviceId: deviceId,
          aggregateId: observation.id,
          kind: 'observation_upsert',
          createdAt: observation.createdAt.add(const Duration(seconds: 1)),
        ),
      ]) {
        await expectLater(
          repository.createTextWithOutbox(
            observation: observation,
            operation: conflict,
          ),
          throwsA(isA<OutboxOperationConflictException>()),
        );
      }
      expect(
        await database.select(database.outboxOperations).get(),
        hasLength(1),
      );
    },
  );

  test(
    'image mutation writes observation asset and one upsert operation',
    () async {
      final aggregate = _imageAggregate(ownerId, deviceId);
      final operation = _operation(
        operationId: _operationId,
        ownerId: ownerId,
        deviceId: deviceId,
        aggregateId: aggregate.observation.id,
        kind: 'observation_upsert',
        createdAt: aggregate.observation.createdAt,
      );

      await repository.createImageWithOutbox(
        aggregate: aggregate,
        operation: operation,
      );
      await repository.createImageWithOutbox(
        aggregate: aggregate,
        operation: operation,
      );

      expect(await database.select(database.observations).get(), hasLength(1));
      expect(await database.select(database.localAssets).get(), hasLength(1));
      final outbox = await database.select(database.outboxOperations).get();
      expect(outbox, hasLength(1));
      expect(outbox.single.operationKind, 'observation_upsert');
    },
  );

  test('image outbox conflict rolls back observation and asset', () async {
    final first = _textObservation(ownerId, deviceId);
    await repository.createTextWithOutbox(
      observation: first,
      operation: _operation(
        operationId: _operationId,
        ownerId: ownerId,
        deviceId: deviceId,
        aggregateId: first.id,
        kind: 'observation_upsert',
        createdAt: first.createdAt,
      ),
    );
    final aggregate = _imageAggregate(ownerId, deviceId);
    await expectLater(
      repository.createImageWithOutbox(
        aggregate: aggregate,
        operation: _operation(
          operationId: _operationId,
          ownerId: ownerId,
          deviceId: deviceId,
          aggregateId: aggregate.observation.id,
          kind: 'observation_upsert',
          createdAt: aggregate.observation.createdAt,
        ),
      ),
      throwsA(isA<OutboxOperationConflictException>()),
    );
    expect(await database.select(database.observations).get(), hasLength(1));
    expect(await database.select(database.localAssets).get(), isEmpty);
  });

  test('delete and restore add operations only when state changes', () async {
    final observation = _textObservation(ownerId, deviceId);
    await repository.create(observation);
    final deletedAt = observation.createdAt.add(const Duration(minutes: 1));
    final deleteOperation = _operation(
      operationId: _deleteOperationId,
      ownerId: ownerId,
      deviceId: deviceId,
      aggregateId: observation.id,
      kind: 'observation_delete',
      createdAt: deletedAt,
    );

    expect(
      await repository.deleteWithOutbox(
        ownerId: ownerId,
        observationId: observation.id,
        deletedAt: deletedAt,
        operation: deleteOperation,
      ),
      ObservationMutationOutcome.changed,
    );
    expect(
      await repository.deleteWithOutbox(
        ownerId: ownerId,
        observationId: observation.id,
        deletedAt: deletedAt,
        operation: deleteOperation,
      ),
      ObservationMutationOutcome.unchanged,
    );
    final restoredAt = deletedAt.add(const Duration(minutes: 1));
    final restoreOperation = _operation(
      operationId: _restoreOperationId,
      ownerId: ownerId,
      deviceId: deviceId,
      aggregateId: observation.id,
      kind: 'observation_upsert',
      createdAt: restoredAt,
    );
    expect(
      await repository.restoreWithOutbox(
        ownerId: ownerId,
        observationId: observation.id,
        restoredAt: restoredAt,
        operation: restoreOperation,
      ),
      ObservationMutationOutcome.changed,
    );
    expect(
      await repository.restoreWithOutbox(
        ownerId: ownerId,
        observationId: observation.id,
        restoredAt: restoredAt,
        operation: restoreOperation,
      ),
      ObservationMutationOutcome.unchanged,
    );
    final outbox = await database.select(database.outboxOperations).get();
    expect(outbox, hasLength(2));
    expect(
      outbox.map((row) => row.operationKind),
      containsAll(['observation_delete', 'observation_upsert']),
    );
  });

  test(
    'delete preserves operation created at separately from deleted at',
    () async {
      final observation = _textObservation(ownerId, deviceId);
      await repository.create(observation);
      final deletedAt = observation.createdAt.add(const Duration(minutes: 1));
      final operationCreatedAt = observation.createdAt.add(
        const Duration(minutes: 2),
      );

      await repository.deleteWithOutbox(
        ownerId: ownerId,
        observationId: observation.id,
        deletedAt: deletedAt,
        operation: _operation(
          operationId: _deleteOperationId,
          ownerId: ownerId,
          deviceId: deviceId,
          aggregateId: observation.id,
          kind: 'observation_delete',
          createdAt: operationCreatedAt,
        ),
      );

      final storedObservation = await (database.select(
        database.observations,
      )..where((table) => table.id.equals(observation.id))).getSingle();
      final storedOperation =
          await (database.select(
                database.outboxOperations,
              )..where((table) => table.operationId.equals(_deleteOperationId)))
              .getSingle();
      expect(storedObservation.deletedAt?.toUtc(), deletedAt);
      expect(storedOperation.createdAt.toUtc(), operationCreatedAt);
    },
  );

  test('delete created-at conflict rolls back the state change', () async {
    final observation = _textObservation(ownerId, deviceId);
    await repository.create(observation);
    final deletedAt = observation.createdAt.add(const Duration(minutes: 1));
    final existingCreatedAt = observation.createdAt.add(
      const Duration(minutes: 2),
    );
    await database
        .into(database.outboxOperations)
        .insert(
          OutboxOperationsCompanion.insert(
            operationId: _deleteOperationId,
            ownerId: ownerId,
            deviceId: deviceId,
            aggregateType: 'observation',
            aggregateId: observation.id,
            operationKind: 'observation_delete',
            createdAt: existingCreatedAt,
          ),
        );

    await expectLater(
      repository.deleteWithOutbox(
        ownerId: ownerId,
        observationId: observation.id,
        deletedAt: deletedAt,
        operation: _operation(
          operationId: _deleteOperationId,
          ownerId: ownerId,
          deviceId: deviceId,
          aggregateId: observation.id,
          kind: 'observation_delete',
          createdAt: existingCreatedAt.add(const Duration(minutes: 1)),
        ),
      ),
      throwsA(isA<OutboxOperationConflictException>()),
    );

    final storedObservation = await (database.select(
      database.observations,
    )..where((table) => table.id.equals(observation.id))).getSingle();
    expect(storedObservation.deletedAt, isNull);
  });

  test(
    'restore preserves operation created at separately from restored at',
    () async {
      final observation = _textObservation(ownerId, deviceId);
      await repository.create(observation);
      final deletedAt = observation.createdAt.add(const Duration(minutes: 1));
      await repository.deleteObservation(
        ownerId: ownerId,
        observationId: observation.id,
        deletedAt: deletedAt,
      );
      final restoredAt = deletedAt.add(const Duration(minutes: 1));
      final operationCreatedAt = restoredAt.add(const Duration(minutes: 1));

      await repository.restoreWithOutbox(
        ownerId: ownerId,
        observationId: observation.id,
        restoredAt: restoredAt,
        operation: _operation(
          operationId: _restoreOperationId,
          ownerId: ownerId,
          deviceId: deviceId,
          aggregateId: observation.id,
          kind: 'observation_upsert',
          createdAt: operationCreatedAt,
        ),
      );

      final storedObservation = await (database.select(
        database.observations,
      )..where((table) => table.id.equals(observation.id))).getSingle();
      final storedOperation =
          await (database.select(database.outboxOperations)..where(
                (table) => table.operationId.equals(_restoreOperationId),
              ))
              .getSingle();
      expect(storedObservation.deletedAt, isNull);
      expect(storedOperation.createdAt.toUtc(), operationCreatedAt);
    },
  );

  test(
    'concurrent delete and restore each record at most one operation',
    () async {
      final observation = _textObservation(ownerId, deviceId);
      await repository.create(observation);
      final deletedAt = observation.createdAt.add(const Duration(minutes: 1));
      final deleteOutcomes = await Future.wait([
        repository.deleteWithOutbox(
          ownerId: ownerId,
          observationId: observation.id,
          deletedAt: deletedAt,
          operation: _operation(
            operationId: _deleteOperationId,
            ownerId: ownerId,
            deviceId: deviceId,
            aggregateId: observation.id,
            kind: 'observation_delete',
            createdAt: deletedAt,
          ),
        ),
        repository.deleteWithOutbox(
          ownerId: ownerId,
          observationId: observation.id,
          deletedAt: deletedAt,
          operation: _operation(
            operationId: _deleteOperationId2,
            ownerId: ownerId,
            deviceId: deviceId,
            aggregateId: observation.id,
            kind: 'observation_delete',
            createdAt: deletedAt,
          ),
        ),
      ]);
      expect(
        deleteOutcomes.where(
          (outcome) => outcome == ObservationMutationOutcome.changed,
        ),
        hasLength(1),
      );
      expect(
        deleteOutcomes.where(
          (outcome) => outcome == ObservationMutationOutcome.unchanged,
        ),
        hasLength(1),
      );
      expect(
        deleteOutcomes.where(
          (outcome) => outcome == ObservationMutationOutcome.notFound,
        ),
        isEmpty,
      );
      final deletedObservation = await (database.select(
        database.observations,
      )..where((table) => table.id.equals(observation.id))).getSingle();
      expect(deletedObservation.deletedAt, isNotNull);
      final deleteOutbox = await database
          .select(database.outboxOperations)
          .get();
      expect(
        deleteOutbox.where((row) => row.operationKind == 'observation_delete'),
        hasLength(1),
      );
      expect(
        [_deleteOperationId, _deleteOperationId2],
        contains(
          deleteOutbox
              .singleWhere((row) => row.operationKind == 'observation_delete')
              .operationId,
        ),
      );

      final restoredAt = deletedAt.add(const Duration(minutes: 1));
      final restoreOutcomes = await Future.wait([
        repository.restoreWithOutbox(
          ownerId: ownerId,
          observationId: observation.id,
          restoredAt: restoredAt,
          operation: _operation(
            operationId: _restoreOperationId,
            ownerId: ownerId,
            deviceId: deviceId,
            aggregateId: observation.id,
            kind: 'observation_upsert',
            createdAt: restoredAt,
          ),
        ),
        repository.restoreWithOutbox(
          ownerId: ownerId,
          observationId: observation.id,
          restoredAt: restoredAt,
          operation: _operation(
            operationId: _restoreOperationId2,
            ownerId: ownerId,
            deviceId: deviceId,
            aggregateId: observation.id,
            kind: 'observation_upsert',
            createdAt: restoredAt,
          ),
        ),
      ]);
      expect(
        restoreOutcomes.where(
          (outcome) => outcome == ObservationMutationOutcome.changed,
        ),
        hasLength(1),
      );
      expect(
        restoreOutcomes.where(
          (outcome) => outcome == ObservationMutationOutcome.unchanged,
        ),
        hasLength(1),
      );
      expect(
        restoreOutcomes.where(
          (outcome) => outcome == ObservationMutationOutcome.notFound,
        ),
        isEmpty,
      );
      final restoredObservation = await (database.select(
        database.observations,
      )..where((table) => table.id.equals(observation.id))).getSingle();
      expect(restoredObservation.deletedAt, isNull);
      final outbox = await database.select(database.outboxOperations).get();
      expect(outbox, hasLength(2));
      expect(
        outbox.where((row) => row.operationKind == 'observation_upsert'),
        hasLength(1),
      );
      expect(
        [_restoreOperationId, _restoreOperationId2],
        contains(
          outbox
              .singleWhere((row) => row.operationKind == 'observation_upsert')
              .operationId,
        ),
      );
    },
  );
}

Observation _textObservation(
  String ownerId,
  String deviceId, {
  String id = _observationId,
  DateTime? createdAt,
}) {
  final timestamp = createdAt ?? _time;
  return Observation(
    id: id,
    ownerId: ownerId,
    inputType: ObservationInputType.text,
    rawText: 'text',
    capturedAt: timestamp,
    timezoneOffset: 480,
    privacyLevel: PrivacyLevel.normal,
    cloudAiPolicy: CloudAiPolicy.localOnly,
    syncPolicy: SyncPolicy.localOnly,
    createdByDeviceId: deviceId,
    createdAt: timestamp,
    updatedAt: timestamp,
    deletedAt: null,
    serverRevision: null,
  );
}

ImageObservationAggregate _imageAggregate(String ownerId, String deviceId) {
  final observation = Observation(
    id: _imageObservationId,
    ownerId: ownerId,
    inputType: ObservationInputType.image,
    rawText: null,
    capturedAt: _time,
    timezoneOffset: 480,
    privacyLevel: PrivacyLevel.normal,
    cloudAiPolicy: CloudAiPolicy.localOnly,
    syncPolicy: SyncPolicy.localOnly,
    createdByDeviceId: deviceId,
    createdAt: _time,
    updatedAt: _time,
    deletedAt: null,
    serverRevision: null,
  );
  return ImageObservationAggregate(
    observation: observation,
    localAsset: LocalAsset(
      id: _assetId,
      observationId: observation.id,
      localUri: 'originals/asset.jpg',
      analysisDerivativeUri: null,
      localOriginalPresent: true,
      mimeType: 'image/jpeg',
      bytes: 10,
      width: 1,
      height: 1,
      sha256: 'hash',
      exifRemoved: false,
      uploadState: 'local_only',
      createdAt: _time,
      updatedAt: _time,
    ),
  );
}

OutboxOperation _operation({
  required String operationId,
  required String ownerId,
  required String deviceId,
  required String aggregateId,
  required String kind,
  required DateTime createdAt,
}) => OutboxOperation(
  operationId: operationId,
  ownerId: ownerId,
  deviceId: deviceId,
  aggregateType: 'observation',
  aggregateId: aggregateId,
  operationKind: kind,
  createdAt: createdAt,
);

const _observationId = '018f7777-7777-7777-8777-777777777777';
const _observationId2 = '018f7777-7777-7777-8777-777777777778';
const _imageObservationId = '018f7777-7777-7777-8777-777777777779';
const _assetId = '018f8888-8888-7888-8888-888888888888';
const _operationId = '018f9999-9999-7999-8999-999999999999';
const _deleteOperationId = '018f9999-9999-7999-8999-999999999998';
const _restoreOperationId = '018f9999-9999-7999-8999-999999999997';
const _deleteOperationId2 = '018f9999-9999-7999-8999-999999999996';
const _restoreOperationId2 = '018f9999-9999-7999-8999-999999999995';
final _time = DateTime.utc(2026, 7, 28);
