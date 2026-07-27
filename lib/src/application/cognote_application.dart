import 'dart:io';

import 'package:path_provider/path_provider.dart';

import '../database/cognote_database.dart' hide Observation;
import '../identity/application/initialize_local_identity.dart';
import '../identity/data/drift_identity_repository.dart';
import '../identity/domain/identity_repository.dart';
import '../observation/application/create_text_observation.dart';
import '../observation/application/create_image_observation.dart';
import '../observation/application/get_observation_detail.dart';
import '../observation/application/watch_observation_timeline.dart';
import '../observation/data/drift_observation_repository.dart';
import '../observation/data/file_asset_storage.dart';
import '../observation/data/uuid_v7_observation_id_generator.dart';
import '../observation/domain/observation.dart';
import '../observation/domain/observation_detail.dart';
import '../observation/domain/observation_id_generator.dart';
import '../observation/domain/observation_mutation_outcome.dart';

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
    this._getObservationDetail,
    this._observationRepository,
    this._clock,
    this._assetStorage,
  );

  final CognoteDatabase _database;
  final LocalIdentity localIdentity;
  final CreateTextObservation _createTextObservation;
  final CreateImageObservation createImageObservation;
  final WatchObservationTimeline _watchObservationTimeline;
  final GetObservationDetail _getObservationDetail;
  final DriftObservationRepository _observationRepository;
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

      final createTextObservation = CreateTextObservation(
        repository: DriftObservationRepository(database),
        localIdentity: localIdentity,
        idGenerator:
            observationIdGenerator ?? const UuidV7ObservationIdGenerator(),
        utcNow: utcNow ?? _utcNow,
      );
      final repository = DriftObservationRepository(database);
      final storage =
          assetStorage ??
          await (assetStorageFactory ??
              () => _defaultAssetStorage(utcNow ?? _utcNow))();
      final createImageObservation = CreateImageObservation(
        repository: repository,
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
      return CognoteApplication._(
        database,
        localIdentity,
        createTextObservation,
        createImageObservation,
        watchObservationTimeline,
        getObservationDetail,
        repository,
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

  Future<ObservationDetail?> getObservationDetail(String observationId) =>
      _getObservationDetail(observationId);

  Stream<List<Observation>> watchDeletedTimeline() => _observationRepository
      .watchDeletedTimeline(ownerId: localIdentity.principal.id);

  Future<ObservationMutationOutcome> deleteObservation(String observationId) {
    return _observationRepository.deleteObservation(
      ownerId: localIdentity.principal.id,
      observationId: observationId,
      deletedAt: _clock(),
    );
  }

  Future<ObservationMutationOutcome> restoreObservation(String observationId) {
    return _observationRepository.restoreObservation(
      ownerId: localIdentity.principal.id,
      observationId: observationId,
      restoredAt: _clock(),
    );
  }

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
