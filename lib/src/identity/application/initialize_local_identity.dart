import '../domain/identity_repository.dart';

class InitializeLocalIdentity {
  const InitializeLocalIdentity(this._repository);

  final IdentityRepository _repository;

  Future<LocalIdentity> call() => _repository.initialize();
}
