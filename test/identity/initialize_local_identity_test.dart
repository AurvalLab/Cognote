import 'package:cognote/src/database/cognote_database.dart';
import 'package:cognote/src/identity/application/initialize_local_identity.dart';
import 'package:cognote/src/identity/data/drift_identity_repository.dart';
import 'package:cognote/src/identity/domain/principal.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:uuid/uuid.dart';

void main() {
  late CognoteDatabase database;
  late InitializeLocalIdentity initializeIdentity;

  setUp(() {
    database = CognoteDatabase(NativeDatabase.memory());
    initializeIdentity = InitializeLocalIdentity(
      DriftIdentityRepository(database),
    );
  });

  tearDown(() async {
    await database.close();
  });

  test('first initialization creates the anonymous local identity', () async {
    final identity = await initializeIdentity();

    expect(identity.principal.kind, PrincipalKind.anonymous);
    expect(identity.principal.status, PrincipalStatus.active);
    expect(identity.principal.homeRegion, 'cn-mainland');
    expect(identity.principal.dataResidency, 'cn');
    expect(identity.principal.upgradedAt, isNull);
    expect(identity.device.principalId, identity.principal.id);
    for (final id in [
      identity.principal.id,
      identity.device.id,
      identity.device.publicInstallId,
    ]) {
      expect(
        Uuid.isValidUUID(
          fromString: id,
          validationMode: ValidationMode.strictRFC9562,
        ),
        isTrue,
      );
      expect(id[14], '4');
    }
    expect({
      identity.principal.id,
      identity.device.id,
      identity.device.publicInstallId,
    }, hasLength(3));
  });

  test(
    'repeated initialization updates lastSeenAt without changing ids',
    () async {
      var now = DateTime.utc(2026, 7, 25, 10);
      final repository = DriftIdentityRepository(database, now: () => now);
      final initialize = InitializeLocalIdentity(repository);

      final first = await initialize();
      now = now.add(const Duration(minutes: 5));
      final second = await initialize();

      expect(second.principal.id, first.principal.id);
      expect(second.device.id, first.device.id);
      expect(second.device.publicInstallId, first.device.publicInstallId);
      expect(first.device.lastSeenAt, DateTime.utc(2026, 7, 25, 10));
      expect(second.device.lastSeenAt, now);
    },
  );
}
