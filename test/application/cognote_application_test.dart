import 'dart:io';

import 'package:cognote/src/application/cognote_application.dart';
import 'package:cognote/src/database/cognote_database.dart';
import 'package:cognote/src/identity/domain/device_identity.dart' as domain;
import 'package:cognote/src/identity/domain/identity_repository.dart';
import 'package:cognote/src/identity/domain/principal.dart' as domain;

import 'package:cognote/src/observation/domain/observation.dart'
    as observation_domain;
import 'package:cognote/src/observation/domain/observation_id_generator.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('bootstrap initializes identity once and exposes the result', () async {
    final database = _TrackingDatabase();
    var initializationCount = 0;
    final expectedIdentity = _identity('first');

    final application = await CognoteApplication.bootstrap(
      databaseFactory: () => database,
      identityInitializer: (_) async {
        initializationCount++;
        return expectedIdentity;
      },
    );

    expect(initializationCount, 1);
    expect(application.localIdentity, same(expectedIdentity));

    await application.close();
  });

  test('real database bootstrap creates only one local identity', () async {
    final database = CognoteDatabase(NativeDatabase.memory());
    final application = await CognoteApplication.bootstrap(
      databaseFactory: () => database,
    );

    expect(await database.select(database.principals).get(), hasLength(1));
    expect(
      await database.select(database.deviceIdentities).get(),
      hasLength(1),
    );
    expect(
      application.localIdentity.device.principalId,
      application.localIdentity.principal.id,
    );

    await application.close();
  });

  test('reopening the same database preserves identity ids', () async {
    final directory = await Directory.systemTemp.createTemp(
      'cognote_application_',
    );

    try {
      final first = await CognoteApplication.bootstrap(
        databaseFactory: () => CognoteDatabase.open(directory: directory),
      );
      final firstIdentity = first.localIdentity;
      await first.close();

      final second = await CognoteApplication.bootstrap(
        databaseFactory: () => CognoteDatabase.open(directory: directory),
      );
      try {
        expect(second.localIdentity.principal.id, firstIdentity.principal.id);
        expect(second.localIdentity.device.id, firstIdentity.device.id);
        expect(
          second.localIdentity.device.publicInstallId,
          firstIdentity.device.publicInstallId,
        );
      } finally {
        await second.close();
      }
    } finally {
      await _deleteDirectoryWhenReleased(directory);
    }
  });

  test(
    'bootstrap rethrows the original error and closes the database',
    () async {
      final database = _TrackingDatabase();
      final error = StateError('identity initialization failed');

      await expectLater(
        CognoteApplication.bootstrap(
          databaseFactory: () => database,
          identityInitializer: (_) => Future.error(error),
        ),
        throwsA(same(error)),
      );

      expect(database.closeCount, 1);
    },
  );

  test('close closes the database once when called repeatedly', () async {
    final database = _TrackingDatabase();
    final application = await CognoteApplication.bootstrap(
      databaseFactory: () => database,
      identityInitializer: (_) async => _identity('close'),
    );

    await application.close();
    await application.close();

    expect(database.closeCount, 1);
  });

  test('prepares and creates text with the initialized identity', () async {
    final database = CognoteDatabase(NativeDatabase.memory());
    final application = await CognoteApplication.bootstrap(
      databaseFactory: () => database,
      observationIdGenerator: const _FixedObservationIdGenerator(),
      utcNow: () => DateTime.utc(2026, 7, 26, 10),
    );
    try {
      final command = application.prepareTextObservation(
        rawText: 'text',
        timezoneOffset: 480,
      );
      final result = await application.createTextObservation(command);

      expect(command.observationId, _observationId);
      expect(result, isA<observation_domain.Observation>());
      expect(result.ownerId, application.localIdentity.principal.id);
      expect(result.createdByDeviceId, application.localIdentity.device.id);
    } finally {
      await application.close();
    }
  });

  test('creation after close propagates the database error', () async {
    final application = await CognoteApplication.bootstrap(
      databaseFactory: () => CognoteDatabase(NativeDatabase.memory()),
      observationIdGenerator: const _FixedObservationIdGenerator(),
      utcNow: () => DateTime.utc(2026, 7, 26, 10),
    );
    final command = application.prepareTextObservation(
      rawText: 'text',
      timezoneOffset: 480,
    );
    await application.close();

    await expectLater(
      application.createTextObservation(command),
      throwsA(anything),
    );
  });
}

class _TrackingDatabase extends CognoteDatabase {
  _TrackingDatabase() : super(NativeDatabase.memory());

  int closeCount = 0;

  @override
  Future<void> close() async {
    closeCount++;
    await super.close();
  }
}

LocalIdentity _identity(String suffix) {
  final createdAt = DateTime.utc(2026, 7, 25);
  final principal = domain.Principal(
    id: 'principal-$suffix',
    kind: domain.PrincipalKind.anonymous,
    status: domain.PrincipalStatus.active,
    homeRegion: 'cn-mainland',
    dataResidency: 'cn',
    createdAt: createdAt,
    upgradedAt: null,
  );
  return LocalIdentity(
    principal: principal,
    device: domain.DeviceIdentity(
      id: 'device-$suffix',
      principalId: principal.id,
      publicInstallId: 'install-$suffix',
      createdAt: createdAt,
      lastSeenAt: createdAt,
    ),
  );
}

const _observationId = '018f9999-9999-7999-8999-999999999999';

class _FixedObservationIdGenerator implements ObservationIdGenerator {
  const _FixedObservationIdGenerator();

  @override
  String generate() => _observationId;
}

Future<void> _deleteDirectoryWhenReleased(Directory directory) async {
  for (var attempt = 0; attempt < 10; attempt++) {
    try {
      await directory.delete(recursive: true);
      return;
    } on PathAccessException {
      if (attempt == 9) {
        rethrow;
      }
      await Future<void>.delayed(const Duration(milliseconds: 50));
    }
  }
}
