import '../database/cognote_database.dart' hide Observation;
import '../identity/application/initialize_local_identity.dart';
import '../identity/data/drift_identity_repository.dart';
import '../identity/domain/identity_repository.dart';
import '../observation/application/create_text_observation.dart';
import '../observation/data/drift_observation_repository.dart';
import '../observation/data/uuid_v7_observation_id_generator.dart';
import '../observation/domain/observation.dart';
import '../observation/domain/observation_id_generator.dart';

typedef CognoteDatabaseFactory = CognoteDatabase Function();
typedef IdentityInitializer =
    Future<LocalIdentity> Function(CognoteDatabase database);

class CognoteApplication {
  CognoteApplication._(
    this._database,
    this.localIdentity,
    this._createTextObservation,
  );

  final CognoteDatabase _database;
  final LocalIdentity localIdentity;
  final CreateTextObservation _createTextObservation;
  Future<void>? _closeFuture;

  static Future<CognoteApplication> bootstrap({
    CognoteDatabaseFactory? databaseFactory,
    IdentityInitializer? identityInitializer,
    ObservationIdGenerator? observationIdGenerator,
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
      return CognoteApplication._(
        database,
        localIdentity,
        createTextObservation,
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

  Future<void> close() => _closeFuture ??= _database.close();
}

DateTime _utcNow() => DateTime.now().toUtc();
