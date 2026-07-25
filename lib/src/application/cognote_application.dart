import '../database/cognote_database.dart';
import '../identity/application/initialize_local_identity.dart';
import '../identity/data/drift_identity_repository.dart';
import '../identity/domain/identity_repository.dart';

typedef CognoteDatabaseFactory = CognoteDatabase Function();
typedef IdentityInitializer =
    Future<LocalIdentity> Function(CognoteDatabase database);

class CognoteApplication {
  CognoteApplication._(this._database, this.localIdentity);

  final CognoteDatabase _database;
  final LocalIdentity localIdentity;
  Future<void>? _closeFuture;

  static Future<CognoteApplication> bootstrap({
    CognoteDatabaseFactory? databaseFactory,
    IdentityInitializer? identityInitializer,
  }) async {
    final database = (databaseFactory ?? CognoteDatabase.open)();

    try {
      final initializeIdentity =
          identityInitializer ??
          (database) =>
              InitializeLocalIdentity(DriftIdentityRepository(database))();
      final localIdentity = await initializeIdentity(database);
      return CognoteApplication._(database, localIdentity);
    } catch (_) {
      await database.close();
      rethrow;
    }
  }

  Future<void> close() => _closeFuture ??= _database.close();
}
