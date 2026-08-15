import 'package:drift/drift.dart';
import 'package:sqlite3/sqlite3.dart';

import '../../database/cognote_database.dart' as drift;
import '../../outbox/domain/outbox_operation_conflict_exception.dart';
import '../../outbox/domain/outbox_operation.dart';
import '../domain/image_observation_exceptions.dart';
import '../domain/local_asset.dart';
import '../domain/observation.dart';
import '../domain/observation_detail.dart';
import '../domain/observation_mutation_outcome.dart';
import '../domain/observation_outbox_mutation_repository.dart';
import '../domain/observation_query_repository.dart';
import '../domain/observation_exceptions.dart';
import '../domain/observation_repository.dart';
import '../domain/observation_search_result.dart';
import 'observation_search_query.dart';

class DriftObservationRepository
    implements
        ObservationRepository,
        ObservationOutboxMutationRepository,
        ObservationQueryRepository {
  const DriftObservationRepository(this._database);

  final drift.CognoteDatabase _database;

  @override
  Future<Observation> create(Observation observation) =>
      _createTextWithOperation(observation, null);

  @override
  Future<Observation> createTextWithOutbox({
    required Observation observation,
    required OutboxOperation operation,
  }) async {
    _verifyUpsertOperation(operation, observation);
    return _createTextWithOperation(observation, operation);
  }

  Future<Observation> _createTextWithOperation(
    Observation observation,
    OutboxOperation? operation,
  ) {
    return _database.transaction(() async {
      final existing = await _findById(observation.id);
      if (existing != null) {
        final resolved = _resolveExisting(existing, observation);
        await _recordOutboxOperation(operation: operation);
        return resolved;
      }

      try {
        await _database
            .into(_database.observations)
            .insert(_toCompanion(observation));
      } on SqliteException catch (error) {
        if (error.extendedResultCode != 1555) {
          rethrow;
        }
        final raced = await _findById(observation.id);
        if (raced == null) {
          rethrow;
        }
        final resolved = _resolveExisting(raced, observation);
        await _recordOutboxOperation(operation: operation);
        return resolved;
      }
      await _recordOutboxOperation(operation: operation);
      return observation;
    });
  }

  @override
  Future<ImageObservationAggregate> createImage(
    ImageObservationAggregate aggregate,
  ) => _createImageWithOperation(aggregate, null);

  @override
  Future<ImageObservationAggregate> createImageWithOutbox({
    required ImageObservationAggregate aggregate,
    required OutboxOperation operation,
  }) async {
    _verifyUpsertOperation(operation, aggregate.observation);
    return _createImageWithOperation(aggregate, operation);
  }

  Future<ImageObservationAggregate> _createImageWithOperation(
    ImageObservationAggregate aggregate,
    OutboxOperation? operation,
  ) {
    return _database.transaction(() async {
      final existingObservation = await _findById(aggregate.observation.id);
      if (existingObservation != null) {
        _resolveExisting(existingObservation, aggregate.observation);
        final existing = await findImageByObservationId(
          aggregate.observation.id,
        );
        if (existing == null ||
            !_sameAsset(existing.localAsset, aggregate.localAsset)) {
          throw LocalAssetIdConflictException();
        }
        await _recordOutboxOperation(operation: operation);
        return existing;
      }
      final existingAsset =
          await (_database.select(_database.localAssets)
                ..where((table) => table.id.equals(aggregate.localAsset.id)))
              .getSingleOrNull();
      if (existingAsset != null) throw LocalAssetIdConflictException();
      await _database
          .into(_database.observations)
          .insert(_toCompanion(aggregate.observation));
      await _database.localAssets.insertOne(
        _toAssetCompanion(aggregate.localAsset),
      );
      await _recordOutboxOperation(operation: operation);
      return aggregate;
    });
  }

  @override
  Future<ImageObservationAggregate?> findImageByObservationId(String id) async {
    final observation = await _findById(id);
    if (observation == null) return null;
    final row = await (_database.select(
      _database.localAssets,
    )..where((table) => table.observationId.equals(id))).getSingleOrNull();
    if (row == null) return null;
    return ImageObservationAggregate(
      observation: observation,
      localAsset: _assetToDomain(row),
    );
  }

  @override
  Future<bool> isLocalUriReferenced(String localUri) async {
    final row = await (_database.select(
      _database.localAssets,
    )..where((table) => table.localUri.equals(localUri))).getSingleOrNull();
    return row != null;
  }

  @override
  Future<ObservationMutationOutcome> deleteObservation({
    required String ownerId,
    required String observationId,
    required DateTime deletedAt,
  }) => deleteObservationWithOutbox(
    ownerId: ownerId,
    deviceId: '',
    observationId: observationId,
    deletedAt: deletedAt,
    operationId: '',
  );

  @override
  Future<ObservationMutationOutcome> deleteWithOutbox({
    required String ownerId,
    required String observationId,
    required DateTime deletedAt,
    required OutboxOperation operation,
  }) async {
    _verifyMutationOperation(
      operation,
      ownerId: ownerId,
      aggregateId: observationId,
      operationKind: _observationDelete,
    );
    return deleteObservationWithOutbox(
      ownerId: ownerId,
      deviceId: operation.deviceId,
      observationId: observationId,
      deletedAt: deletedAt,
      operationId: operation.operationId,
      operationCreatedAt: operation.createdAt,
    );
  }

  Future<ObservationMutationOutcome> deleteObservationWithOutbox({
    required String ownerId,
    required String deviceId,
    required String observationId,
    required DateTime deletedAt,
    required String operationId,
    DateTime? operationCreatedAt,
  }) {
    return _database.transaction(() async {
      final affectedRows =
          await (_database.update(_database.observations)..where(
                (table) =>
                    table.id.equals(observationId) &
                    table.ownerId.equals(ownerId) &
                    table.deletedAt.isNull(),
              ))
              .write(
                drift.ObservationsCompanion(
                  deletedAt: Value<DateTime?>(deletedAt),
                  updatedAt: Value(deletedAt),
                ),
              );
      if (affectedRows == 1) {
        await _recordOutboxOperation(
          operationId: operationId,
          ownerId: ownerId,
          deviceId: deviceId,
          aggregateId: observationId,
          operationKind: _observationDelete,
          createdAt: operationCreatedAt ?? deletedAt,
        );
        return ObservationMutationOutcome.changed;
      }
      final existing = await _findOwnedById(ownerId, observationId);
      return existing == null
          ? ObservationMutationOutcome.notFound
          : ObservationMutationOutcome.unchanged;
    });
  }

  @override
  Future<ObservationMutationOutcome> restoreObservation({
    required String ownerId,
    required String observationId,
    required DateTime restoredAt,
  }) => restoreObservationWithOutbox(
    ownerId: ownerId,
    deviceId: '',
    observationId: observationId,
    restoredAt: restoredAt,
    operationId: '',
  );

  @override
  Future<ObservationMutationOutcome> restoreWithOutbox({
    required String ownerId,
    required String observationId,
    required DateTime restoredAt,
    required OutboxOperation operation,
  }) async {
    _verifyMutationOperation(
      operation,
      ownerId: ownerId,
      aggregateId: observationId,
      operationKind: _observationUpsert,
    );
    return restoreObservationWithOutbox(
      ownerId: ownerId,
      deviceId: operation.deviceId,
      observationId: observationId,
      restoredAt: restoredAt,
      operationId: operation.operationId,
      operationCreatedAt: operation.createdAt,
    );
  }

  Future<ObservationMutationOutcome> restoreObservationWithOutbox({
    required String ownerId,
    required String deviceId,
    required String observationId,
    required DateTime restoredAt,
    required String operationId,
    DateTime? operationCreatedAt,
  }) {
    return _database.transaction(() async {
      final affectedRows =
          await (_database.update(_database.observations)..where(
                (table) =>
                    table.id.equals(observationId) &
                    table.ownerId.equals(ownerId) &
                    table.deletedAt.isNotNull(),
              ))
              .write(
                drift.ObservationsCompanion(
                  deletedAt: const Value<DateTime?>(null),
                  updatedAt: Value(restoredAt),
                ),
              );
      if (affectedRows == 1) {
        await _recordOutboxOperation(
          operationId: operationId,
          ownerId: ownerId,
          deviceId: deviceId,
          aggregateId: observationId,
          operationKind: _observationUpsert,
          createdAt: operationCreatedAt ?? restoredAt,
        );
        return ObservationMutationOutcome.changed;
      }
      final existing = await _findOwnedById(ownerId, observationId);
      return existing == null
          ? ObservationMutationOutcome.notFound
          : ObservationMutationOutcome.unchanged;
    });
  }

  @override
  Stream<List<Observation>> watchActiveTimeline({required String ownerId}) {
    final query = _database.select(_database.observations)
      ..where(
        (table) => table.ownerId.equals(ownerId) & table.deletedAt.isNull(),
      )
      ..orderBy([
        (table) => OrderingTerm.desc(table.capturedAt),
        (table) => OrderingTerm.desc(table.createdAt),
        (table) => OrderingTerm.desc(table.id),
      ]);
    return query.watch().map(
      (rows) => rows.map(_toDomain).toList(growable: false),
    );
  }

  @override
  Stream<List<Observation>> watchDeletedTimeline({required String ownerId}) {
    final query = _database.select(_database.observations)
      ..where(
        (table) => table.ownerId.equals(ownerId) & table.deletedAt.isNotNull(),
      )
      ..orderBy([
        (table) => OrderingTerm.desc(table.deletedAt),
        (table) => OrderingTerm.desc(table.capturedAt),
        (table) => OrderingTerm.desc(table.createdAt),
        (table) => OrderingTerm.desc(table.id),
      ]);
    return query.watch().map(
      (rows) => rows.map(_toDomain).toList(growable: false),
    );
  }

  @override
  Stream<List<ObservationSearchResult>> watchActiveSearch({
    required String ownerId,
    required String query,
  }) {
    final compiled = ObservationSearchQuery.compile(query);
    if (compiled.normalized.isEmpty) return Stream.value(const []);

    final variables = <Variable<String>>[Variable.withString(ownerId)];
    final conditions = <String>[
      'observation.owner_id = ?',
      'observation.deleted_at IS NULL',
    ];
    if (compiled.matchExpression != null) {
      conditions.add('observation_search_fts MATCH ?');
      variables.add(Variable.withString(compiled.matchExpression!));
    }
    for (final term in compiled.shortTextVariables) {
      conditions.add(
        "instr(lower(coalesce(observation.raw_text, '')), lower(?)) > 0",
      );
      variables.add(Variable.withString(term));
    }
    final statement =
        '''
      SELECT observation.*
      FROM observations AS observation
      ${compiled.matchExpression == null ? '' : 'JOIN observation_search_fts AS search ON search.observation_id = observation.id'}
      WHERE ${conditions.join(' AND ')}
      ORDER BY observation.captured_at DESC,
               observation.created_at DESC,
               observation.id DESC
    ''';
    return _database
        .customSelect(
          statement,
          variables: variables,
          readsFrom: {_database.observations},
        )
        .watch()
        .map(
          (rows) => rows
              .map((row) {
                final observation = _observationFromRow(row);
                return ObservationSearchResult(
                  observation: observation,
                  snippet: ObservationSearchQuery.snippet(
                    observation.rawText ?? '',
                    [...compiled.longTerms, ...compiled.shortTerms],
                  ),
                );
              })
              .toList(growable: false),
        );
  }

  @override
  Future<ObservationDetail?> findActiveDetail({
    required String ownerId,
    required String observationId,
  }) async {
    final observationRow =
        await (_database.select(_database.observations)..where(
              (table) =>
                  table.id.equals(observationId) &
                  table.ownerId.equals(ownerId) &
                  table.deletedAt.isNull(),
            ))
            .getSingleOrNull();
    if (observationRow == null) return null;

    final observation = _toDomain(observationRow);
    if (observation.inputType == ObservationInputType.text) {
      return ObservationDetail(observation: observation, localAsset: null);
    }

    final assetRow =
        await (_database.select(_database.localAssets)
              ..where((table) => table.observationId.equals(observationId)))
            .getSingleOrNull();
    if (assetRow == null) throw AssetIntegrityException();
    return ObservationDetail(
      observation: observation,
      localAsset: _assetToDomain(assetRow),
    );
  }

  Observation _observationFromRow(QueryRow row) => Observation(
    id: row.read<String>('id'),
    ownerId: row.read<String>('owner_id'),
    inputType: _inputTypeFromDatabase(row.read<String>('input_type')),
    rawText: row.readNullable<String>('raw_text'),
    capturedAt: row.read<DateTime>('captured_at').toUtc(),
    timezoneOffset: row.read<int>('timezone_offset'),
    privacyLevel: _privacyLevelFromDatabase(row.read<String>('privacy_level')),
    cloudAiPolicy: _cloudAiPolicyFromDatabase(
      row.read<String>('cloud_ai_policy'),
    ),
    syncPolicy: _syncPolicyFromDatabase(row.read<String>('sync_policy')),
    createdByDeviceId: row.read<String>('created_by_device_id'),
    createdAt: row.read<DateTime>('created_at').toUtc(),
    updatedAt: row.read<DateTime>('updated_at').toUtc(),
    deletedAt: row.readNullable<DateTime>('deleted_at')?.toUtc(),
    serverRevision: row.readNullable<int>('server_revision'),
  );

  Future<Observation?> _findById(String id) async {
    final row = await (_database.select(
      _database.observations,
    )..where((table) => table.id.equals(id))).getSingleOrNull();
    return row == null ? null : _toDomain(row);
  }

  Future<Observation?> _findOwnedById(String ownerId, String id) async {
    final row =
        await (_database.select(_database.observations)..where(
              (table) => table.id.equals(id) & table.ownerId.equals(ownerId),
            ))
            .getSingleOrNull();
    return row == null ? null : _toDomain(row);
  }

  Observation _resolveExisting(Observation existing, Observation requested) {
    if (existing.deletedAt != null || !_sameCreation(existing, requested)) {
      throw ObservationIdConflictException();
    }
    return existing;
  }

  bool _sameCreation(Observation left, Observation right) {
    return left.id == right.id &&
        left.ownerId == right.ownerId &&
        left.createdByDeviceId == right.createdByDeviceId &&
        left.inputType == right.inputType &&
        left.rawText == right.rawText &&
        _sameDatabaseInstant(left.capturedAt, right.capturedAt) &&
        left.timezoneOffset == right.timezoneOffset &&
        left.privacyLevel == right.privacyLevel &&
        left.cloudAiPolicy == right.cloudAiPolicy &&
        left.syncPolicy == right.syncPolicy;
  }

  drift.ObservationsCompanion _toCompanion(Observation observation) {
    return drift.ObservationsCompanion.insert(
      id: observation.id,
      ownerId: observation.ownerId,
      inputType: _inputTypeToDatabase(observation.inputType),
      rawText: Value(observation.rawText),
      capturedAt: observation.capturedAt,
      timezoneOffset: observation.timezoneOffset,
      privacyLevel: _privacyLevelToDatabase(observation.privacyLevel),
      cloudAiPolicy: _cloudAiPolicyToDatabase(observation.cloudAiPolicy),
      syncPolicy: _syncPolicyToDatabase(observation.syncPolicy),
      createdByDeviceId: observation.createdByDeviceId,
      createdAt: observation.createdAt,
      updatedAt: observation.updatedAt,
      deletedAt: Value(observation.deletedAt),
      serverRevision: Value(observation.serverRevision),
    );
  }

  drift.LocalAssetsCompanion _toAssetCompanion(LocalAsset asset) =>
      drift.LocalAssetsCompanion.insert(
        id: asset.id,
        observationId: asset.observationId,
        localUri: asset.localUri,
        analysisDerivativeUri: Value(asset.analysisDerivativeUri),
        localOriginalPresent: asset.localOriginalPresent,
        mimeType: asset.mimeType,
        bytes: asset.bytes,
        width: Value(asset.width),
        height: Value(asset.height),
        sha256: asset.sha256,
        exifRemoved: asset.exifRemoved,
        uploadState: asset.uploadState,
        createdAt: asset.createdAt,
        updatedAt: asset.updatedAt,
      );

  LocalAsset _assetToDomain(drift.LocalAsset row) => LocalAsset(
    id: row.id,
    observationId: row.observationId,
    localUri: row.localUri,
    analysisDerivativeUri: row.analysisDerivativeUri,
    localOriginalPresent: row.localOriginalPresent,
    mimeType: row.mimeType,
    bytes: row.bytes,
    width: row.width,
    height: row.height,
    sha256: row.sha256,
    exifRemoved: row.exifRemoved,
    uploadState: row.uploadState,
    createdAt: row.createdAt.toUtc(),
    updatedAt: row.updatedAt.toUtc(),
  );

  bool _sameAsset(LocalAsset left, LocalAsset right) =>
      left.id == right.id &&
      left.observationId == right.observationId &&
      left.localUri == right.localUri &&
      left.analysisDerivativeUri == right.analysisDerivativeUri &&
      left.localOriginalPresent == right.localOriginalPresent &&
      left.mimeType == right.mimeType &&
      left.bytes == right.bytes &&
      left.width == right.width &&
      left.height == right.height &&
      left.sha256 == right.sha256 &&
      left.exifRemoved == right.exifRemoved &&
      left.uploadState == right.uploadState;

  void _verifyUpsertOperation(
    OutboxOperation operation,
    Observation observation,
  ) {
    _verifyMutationOperation(
      operation,
      ownerId: observation.ownerId,
      aggregateId: observation.id,
      operationKind: _observationUpsert,
    );
    if (operation.deviceId != observation.createdByDeviceId ||
        operation.createdAt.toUtc() != observation.createdAt.toUtc()) {
      throw OutboxOperationConflictException();
    }
  }

  void _verifyMutationOperation(
    OutboxOperation operation, {
    required String ownerId,
    required String aggregateId,
    required String operationKind,
  }) {
    if (operation.ownerId != ownerId ||
        operation.aggregateType != _observationAggregate ||
        operation.aggregateId != aggregateId ||
        operation.operationKind != operationKind) {
      throw OutboxOperationConflictException();
    }
  }

  Future<void> _recordOutboxOperation({
    OutboxOperation? operation,
    String? operationId,
    String? ownerId,
    String? deviceId,
    String? aggregateId,
    String? operationKind,
    DateTime? createdAt,
  }) async {
    final outboxOperation =
        operation ??
        (operationId == null ||
                operationId.isEmpty ||
                ownerId == null ||
                deviceId == null ||
                deviceId.isEmpty ||
                aggregateId == null ||
                operationKind == null ||
                createdAt == null
            ? null
            : OutboxOperation(
                operationId: operationId,
                ownerId: ownerId,
                deviceId: deviceId,
                aggregateType: _observationAggregate,
                aggregateId: aggregateId,
                operationKind: operationKind,
                createdAt: createdAt,
              ));
    if (outboxOperation == null) return;
    final existingBeforeInsert =
        await (_database.select(_database.outboxOperations)..where(
              (table) => table.operationId.equals(outboxOperation.operationId),
            ))
            .getSingleOrNull();
    if (existingBeforeInsert != null) {
      _verifyStoredOperation(existingBeforeInsert, outboxOperation);
      return;
    }
    await _database
        .into(_database.outboxOperations)
        .insert(
          drift.OutboxOperationsCompanion.insert(
            operationId: outboxOperation.operationId,
            ownerId: outboxOperation.ownerId,
            deviceId: outboxOperation.deviceId,
            aggregateType: outboxOperation.aggregateType,
            aggregateId: outboxOperation.aggregateId,
            operationKind: outboxOperation.operationKind,
            createdAt: outboxOperation.createdAt,
          ),
          mode: InsertMode.insertOrIgnore,
        );
    final existing =
        await (_database.select(_database.outboxOperations)..where(
              (table) => table.operationId.equals(outboxOperation.operationId),
            ))
            .getSingleOrNull();
    if (existing == null) {
      throw StateError('Outbox operation was not persisted');
    }
    _verifyStoredOperation(existing, outboxOperation);
  }

  void _verifyStoredOperation(
    drift.OutboxOperationRow existing,
    OutboxOperation operation,
  ) {
    if (existing.ownerId != operation.ownerId ||
        existing.deviceId != operation.deviceId ||
        existing.aggregateType != operation.aggregateType ||
        existing.aggregateId != operation.aggregateId ||
        existing.operationKind != operation.operationKind ||
        !_sameDatabaseInstant(existing.createdAt, operation.createdAt)) {
      throw OutboxOperationConflictException();
    }
  }

  Observation _toDomain(drift.Observation row) {
    return Observation(
      id: row.id,
      ownerId: row.ownerId,
      inputType: _inputTypeFromDatabase(row.inputType),
      rawText: row.rawText,
      capturedAt: row.capturedAt.toUtc(),
      timezoneOffset: row.timezoneOffset,
      privacyLevel: _privacyLevelFromDatabase(row.privacyLevel),
      cloudAiPolicy: _cloudAiPolicyFromDatabase(row.cloudAiPolicy),
      syncPolicy: _syncPolicyFromDatabase(row.syncPolicy),
      createdByDeviceId: row.createdByDeviceId,
      createdAt: row.createdAt.toUtc(),
      updatedAt: row.updatedAt.toUtc(),
      deletedAt: row.deletedAt?.toUtc(),
      serverRevision: row.serverRevision,
    );
  }
}

bool _sameDatabaseInstant(DateTime left, DateTime right) =>
    left.millisecondsSinceEpoch ~/ Duration.millisecondsPerSecond ==
    right.millisecondsSinceEpoch ~/ Duration.millisecondsPerSecond;

String _inputTypeToDatabase(ObservationInputType value) => value.name;

ObservationInputType _inputTypeFromDatabase(String value) =>
    ObservationInputType.values.byName(value);

String _privacyLevelToDatabase(PrivacyLevel value) => value.name;

PrivacyLevel _privacyLevelFromDatabase(String value) =>
    PrivacyLevel.values.byName(value);

String _cloudAiPolicyToDatabase(CloudAiPolicy value) => switch (value) {
  CloudAiPolicy.localOnly => 'local_only',
  CloudAiPolicy.consentRequired => 'consent_required',
  CloudAiPolicy.allowed => 'allowed',
};

CloudAiPolicy _cloudAiPolicyFromDatabase(String value) => switch (value) {
  'local_only' => CloudAiPolicy.localOnly,
  'consent_required' => CloudAiPolicy.consentRequired,
  'allowed' => CloudAiPolicy.allowed,
  _ => throw StateError('Unknown cloud AI policy: $value'),
};

String _syncPolicyToDatabase(SyncPolicy value) => switch (value) {
  SyncPolicy.localOnly => 'local_only',
  SyncPolicy.syncEnabled => 'sync_enabled',
};

SyncPolicy _syncPolicyFromDatabase(String value) => switch (value) {
  'local_only' => SyncPolicy.localOnly,
  'sync_enabled' => SyncPolicy.syncEnabled,
  _ => throw StateError('Unknown sync policy: $value'),
};

const _observationAggregate = 'observation';
const _observationUpsert = 'observation_upsert';
const _observationDelete = 'observation_delete';
