import 'package:drift/drift.dart';
import 'package:sqlite3/sqlite3.dart';

import '../../database/cognote_database.dart' as drift;
import '../domain/observation.dart';
import '../domain/observation_exceptions.dart';
import '../domain/observation_repository.dart';

class DriftObservationRepository implements ObservationRepository {
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
