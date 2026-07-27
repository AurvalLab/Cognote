import 'package:drift/drift.dart';
import 'package:sqlite3/sqlite3.dart';

import '../../database/cognote_database.dart' as drift;
import '../domain/image_observation_exceptions.dart';
import '../domain/local_asset.dart';
import '../domain/observation.dart';
import '../domain/observation_detail.dart';
import '../domain/observation_query_repository.dart';
import '../domain/observation_exceptions.dart';
import '../domain/observation_repository.dart';

class DriftObservationRepository
    implements ObservationRepository, ObservationQueryRepository {
  const DriftObservationRepository(this._database);

  final drift.CognoteDatabase _database;

  @override
  Future<Observation> create(Observation observation) {
    return _database.transaction(() async {
      final existing = await _findById(observation.id);
      if (existing != null) {
        return _resolveExisting(existing, observation);
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
        return _resolveExisting(raced, observation);
      }
      return observation;
    });
  }

  @override
  Future<ImageObservationAggregate> createImage(
    ImageObservationAggregate aggregate,
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

  Future<Observation?> _findById(String id) async {
    final row = await (_database.select(
      _database.observations,
    )..where((table) => table.id.equals(id))).getSingleOrNull();
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
        left.capturedAt == right.capturedAt &&
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
