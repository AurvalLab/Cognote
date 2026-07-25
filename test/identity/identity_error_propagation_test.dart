import 'package:cognote/src/identity/application/initialize_local_identity.dart';
import 'package:cognote/src/identity/domain/identity_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'repository exceptions propagate through the application use case',
    () async {
      final initialize = InitializeLocalIdentity(_FailingRepository());

      await expectLater(initialize(), throwsA(isA<StateError>()));
    },
  );
}

class _FailingRepository implements IdentityRepository {
  @override
  Future<LocalIdentity> initialize() =>
      Future.error(StateError('database failed'));
}
