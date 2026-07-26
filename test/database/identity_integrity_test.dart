import 'package:cognote/src/database/cognote_database.dart';
import 'package:cognote/src/identity/application/initialize_local_identity.dart';
import 'package:cognote/src/identity/data/drift_identity_repository.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late CognoteDatabase database;

  setUp(() {
    database = CognoteDatabase(NativeDatabase.memory());
  });

  tearDown(() async {
    await database.close();
  });

  test('concurrent repositories produce one identity', () async {
    final first = InitializeLocalIdentity(DriftIdentityRepository(database));
    final second = InitializeLocalIdentity(DriftIdentityRepository(database));

    final identities = await Future.wait([
      first(),
      second(),
      first(),
      second(),
      first(),
      second(),
      first(),
      second(),
    ]);

    expect(identities.map((item) => item.principal.id).toSet(), hasLength(1));
    expect(identities.map((item) => item.device.id).toSet(), hasLength(1));
    expect(
      identities.map((item) => item.device.publicInstallId).toSet(),
      hasLength(1),
    );
    expect(await database.select(database.principals).get(), hasLength(1));
    expect(
      await database.select(database.deviceIdentities).get(),
      hasLength(1),
    );
  });

  test('device insert failure rolls back the principal insert', () async {
    await database.customStatement(
      "CREATE TRIGGER fail_device_insert "
      "BEFORE INSERT ON device_identities "
      "BEGIN SELECT RAISE(ABORT, 'forced device insert failure'); END",
    );
    final repository = DriftIdentityRepository(database);

    await expectLater(repository.initialize(), throwsA(isA<SqliteException>()));

    expect(await database.select(database.principals).get(), isEmpty);
    expect(await database.select(database.deviceIdentities).get(), isEmpty);
  });

  test('foreign key rejects an orphan device identity', () async {
    final now = DateTime.utc(2026, 7, 25);

    await expectLater(
      database
          .into(database.deviceIdentities)
          .insert(
            DeviceIdentitiesCompanion.insert(
              id: '22222222-2222-4222-8222-222222222222',
              principalId: 'missing-principal',
              publicInstallId: '33333333-3333-4333-8333-333333333333',
              createdAt: now,
              lastSeenAt: now,
            ),
          ),
      throwsA(isA<SqliteException>()),
    );
    expect(await database.select(database.deviceIdentities).get(), isEmpty);
  });

  test('database starts at current schema version', () async {
    await database.customSelect('SELECT 1').getSingle();

    final version = await database
        .customSelect('PRAGMA user_version')
        .getSingle();
    expect(version.read<int>('user_version'), 2);
  });
}
