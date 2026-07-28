import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

import '../database/cognote_database.dart' hide Observation;
import '../identity/application/initialize_local_identity.dart';
import '../identity/data/drift_identity_repository.dart';
import '../identity/domain/identity_repository.dart';
import '../observation/application/create_text_observation.dart';
import '../observation/application/create_image_observation.dart';
import '../observation/application/get_observation_detail.dart';
import '../observation/application/watch_observation_timeline.dart';
import '../observation/application/watch_observation_search.dart';
import '../observation/data/drift_observation_repository.dart';
import '../observation/data/file_asset_storage.dart';
import '../observation/data/uuid_v7_observation_id_generator.dart';
import '../observation/domain/observation.dart';
import '../observation/domain/observation_detail.dart';
import '../observation/domain/observation_id_generator.dart';
import '../observation/domain/observation_mutation_outcome.dart';
import '../observation/domain/observation_outbox_mutation_repository.dart';
import '../observation/domain/observation_search_result.dart';

import '../outbox/data/drift_outbox_query_repository.dart';
import '../outbox/domain/outbox_operation.dart';
import '../outbox/domain/outbox_query_repository.dart';

typedef CognoteDatabaseFactory = CognoteDatabase Function();
typedef IdentityInitializer =
    Future<LocalIdentity> Function(CognoteDatabase database);
typedef AssetStorageFactory = Future<FileAssetStorage> Function();

class CognoteApplication {
  CognoteApplication._(
    this._database,
    this.localIdentity,
    this._createTextObservation,
    this.createImageObservation,
    this._watchObservationTimeline,
    this._watchObservationSearch,
    this._getObservationDetail,
    this._observationRepository,
    this._outboxMutationRepository,
    this._outboxQueryRepository,
    this._clock,
    this._assetStorage,
  );

  final CognoteDatabase _database;
  final LocalIdentity localIdentity;
  final CreateTextObservation _createTextObservation;
  final CreateImageObservation createImageObservation;
  final WatchObservationTimeline _watchObservationTimeline;
  final WatchObservationSearch _watchObservationSearch;
  final GetObservationDetail _getObservationDetail;
  final DriftObservationRepository _observationRepository;
  final ObservationOutboxMutationRepository? _outboxMutationRepository;
  final OutboxQueryRepository _outboxQueryRepository;
  final UtcNow _clock;
  final FileAssetStorage _assetStorage;
  Future<void>? _closeFuture;

  static Future<CognoteApplication> bootstrap({
    CognoteDatabaseFactory? databaseFactory,
    IdentityInitializer? identityInitializer,
    ObservationIdGenerator? observationIdGenerator,
    ObservationIdGenerator? localAssetIdGenerator,
    FileAssetStorage? assetStorage,
    AssetStorageFactory? assetStorageFactory,
    UtcNow? utcNow,
  }) async {
    final database = (databaseFactory ?? CognoteDatabase.open)();

    try {
      final initializeIdentity =
          identityInitializer ??
          (database) =>
              InitializeLocalIdentity(DriftIdentityRepository(database))();
      final localIdentity = await initializeIdentity(database);

      final repository = DriftObservationRepository(database);
      final createTextObservation = CreateTextObservation(
        repository: repository,
        outboxMutationRepository: repository,
        localIdentity: localIdentity,
        idGenerator:
            observationIdGenerator ?? const UuidV7ObservationIdGenerator(),
        utcNow: utcNow ?? _utcNow,
      );
      final storage =
          assetStorage ??
          await (assetStorageFactory ??
              () => _defaultAssetStorage(utcNow ?? _utcNow))();
      final createImageObservation = CreateImageObservation(
        repository: repository,
        outboxMutationRepository: repository,
        localIdentity: localIdentity,
        observationIdGenerator:
            observationIdGenerator ?? const UuidV7ObservationIdGenerator(),
        localAssetIdGenerator:
            localAssetIdGenerator ?? const UuidV7ObservationIdGenerator(),
        assetStorage: storage,
        clock: utcNow ?? _utcNow,
      );
      final watchObservationTimeline = WatchObservationTimeline(
        repository: repository,
        localIdentity: localIdentity,
      );
      final getObservationDetail = GetObservationDetail(
        repository: repository,
        localIdentity: localIdentity,
      );
      final watchObservationSearch = WatchObservationSearch(
        repository: repository,
        localIdentity: localIdentity,
      );
      return CognoteApplication._(
        database,
        localIdentity,
        createTextObservation,
        createImageObservation,
        watchObservationTimeline,
        watchObservationSearch,
        getObservationDetail,
        repository,
        repository,
        DriftOutboxQueryRepository(database),
        utcNow ?? _utcNow,
        storage,
      );
    } catch (_) {
      await database.close();
      rethrow;
    }
  }

  CreateTextObservationCommand prepareTextObservation({
    required String rawText,
    required int timezoneOffset,
    DateTime? capturedAtUtc,
  }) {
    return _createTextObservation.prepare(
      rawText: rawText,
      timezoneOffset: timezoneOffset,
      capturedAtUtc: capturedAtUtc,
    );
  }

  Future<Observation> createTextObservation(
    CreateTextObservationCommand command,
  ) => _createTextObservation.execute(command);

  Stream<List<Observation>> watchTimeline() => _watchObservationTimeline();

  Stream<List<ObservationSearchResult>> watchSearch(String query) =>
      _watchObservationSearch(query);

  Future<ObservationDetail?> getObservationDetail(String observationId) =>
      _getObservationDetail(observationId);

  Stream<List<Observation>> watchDeletedTimeline() => _observationRepository
      .watchDeletedTimeline(ownerId: localIdentity.principal.id);

  Future<ObservationMutationOutcome> deleteObservation(String observationId) {
    final createdAt = _clock();
    return _requireOutboxMutationRepository().deleteWithOutbox(
      ownerId: localIdentity.principal.id,
      observationId: observationId,
      deletedAt: createdAt,
      operation: _operation(
        operationId: const Uuid().v7(),
        aggregateId: observationId,
        operationKind: 'observation_delete',
        createdAt: createdAt,
      ),
    );
  }

  Future<ObservationMutationOutcome> restoreObservation(String observationId) {
    final createdAt = _clock();
    return _requireOutboxMutationRepository().restoreWithOutbox(
      ownerId: localIdentity.principal.id,
      observationId: observationId,
      restoredAt: createdAt,
      operation: _operation(
        operationId: const Uuid().v7(),
        aggregateId: observationId,
        operationKind: 'observation_upsert',
        createdAt: createdAt,
      ),
    );
  }

  Future<List<OutboxOperation>> listPendingOutbox() =>
      _outboxQueryRepository.listPending(ownerId: localIdentity.principal.id);

  ObservationOutboxMutationRepository _requireOutboxMutationRepository() =>
      _outboxMutationRepository ??
      (throw StateError('Observation outbox mutation repository is required'));

  OutboxOperation _operation({
    required String operationId,
    required String aggregateId,
    required String operationKind,
    required DateTime createdAt,
  }) => OutboxOperation(
    operationId: operationId,
    ownerId: localIdentity.principal.id,
    deviceId: localIdentity.device.id,
    aggregateType: 'observation',
    aggregateId: aggregateId,
    operationKind: operationKind,
    createdAt: createdAt,
  );

  File resolveLocalAsset(String localUri) =>
      _assetStorage.resolveLocalFile(localUri);

  Future<void> close() => _closeFuture ??= Future.wait([
    _database.close(),
    _assetStorage.close(),
  ]).then((_) {});
}

DateTime _utcNow() => DateTime.now().toUtc();

Future<FileAssetStorage> _defaultAssetStorage(Clock clock) async {
  final supportDirectory = await getApplicationSupportDirectory();
  return FileAssetStorage(
    root: Directory('${supportDirectory.path}/assets'),
    clock: clock,
  );
}
