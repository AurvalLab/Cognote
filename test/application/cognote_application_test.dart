import 'dart:io';
import 'dart:typed_data';

import 'package:cognote/src/application/cognote_application.dart';
import 'package:cognote/src/database/cognote_database.dart';
import 'package:cognote/src/identity/domain/device_identity.dart' as domain;
import 'package:cognote/src/identity/domain/identity_repository.dart';
import 'package:cognote/src/identity/domain/principal.dart' as domain;
import 'package:cognote/src/observation/data/file_asset_storage.dart';
import 'package:cognote/src/observation/domain/image_source.dart';
import 'package:cognote/src/observation/domain/observation.dart'
    as observation_domain;
import 'package:cognote/src/observation/domain/observation_id_generator.dart';
import 'package:cognote/src/observation/domain/observation_repository.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;

void main() {
  late Directory assetRoot;

  setUp(() async {
    assetRoot = await Directory.systemTemp.createTemp('cng104_application_');
  });

  tearDown(() async {
    if (await assetRoot.exists()) {
      await assetRoot.delete(recursive: true);
    }
  });

  FileAssetStorage storage({bool deleteRootOnClose = false}) {
    return FileAssetStorage(
      root: assetRoot,
      clock: () => DateTime.utc(2026, 7, 26),
      deleteRootOnClose: deleteRootOnClose,
    );
  }

  test(
    'bootstrap exposes image creation with injected asset storage',
    () async {
      final database = CognoteDatabase(NativeDatabase.memory());
      final application = await CognoteApplication.bootstrap(
        databaseFactory: () => database,
        assetStorage: storage(),
      );
      try {
        expect(application.createImageObservation, isNotNull);
        expect(application.localIdentity.principal.id, isNotEmpty);
      } finally {
        await application.close();
        await application.close();
      }
    },
  );

  test(
    'close preserves asset files and isolated roots do not interfere',
    () async {
      final firstRoot = await Directory.systemTemp.createTemp(
        'cng104_app_first_',
      );
      final secondRoot = await Directory.systemTemp.createTemp(
        'cng104_app_second_',
      );
      final firstFile = File('${firstRoot.path}/originals/01/first.jpg');
      final secondFile = File('${secondRoot.path}/originals/01/second.jpg');
      await firstFile.parent.create(recursive: true);
      await secondFile.parent.create(recursive: true);
      await firstFile.writeAsBytes([1]);
      await secondFile.writeAsBytes([2]);

      final first = await CognoteApplication.bootstrap(
        databaseFactory: () => CognoteDatabase(NativeDatabase.memory()),
        assetStorage: FileAssetStorage(
          root: firstRoot,
          clock: () => DateTime.utc(2026, 7, 26),
        ),
      );
      await first.close();

      final second = await CognoteApplication.bootstrap(
        databaseFactory: () => CognoteDatabase(NativeDatabase.memory()),
        assetStorage: FileAssetStorage(
          root: secondRoot,
          clock: () => DateTime.utc(2026, 7, 26),
        ),
      );
      try {
        expect(firstFile.existsSync(), isTrue);
        expect(secondFile.existsSync(), isTrue);
        await second.close();
        expect(secondFile.existsSync(), isTrue);
      } finally {
        if (await firstRoot.exists()) await firstRoot.delete(recursive: true);
        if (await secondRoot.exists()) await secondRoot.delete(recursive: true);
      }
    },
  );

  test('test-owned asset storage removes its isolated root on close', () async {
    final root = await Directory.systemTemp.createTemp('cng104_app_owned_');
    final file = File('${root.path}/originals/01/test.jpg');
    await file.parent.create(recursive: true);
    await file.writeAsBytes([1]);

    final application = await CognoteApplication.bootstrap(
      databaseFactory: () => CognoteDatabase(NativeDatabase.memory()),
      assetStorage: FileAssetStorage(
        root: root,
        clock: () => DateTime.utc(2026, 7, 26),
        deleteRootOnClose: true,
      ),
    );

    await application.close();
    expect(root.existsSync(), isFalse);
  });

  test(
    'custom identity bootstrap defers reconciliation until image prepare',
    () async {
      final counting = _CountingAssetStorage(
        root: assetRoot,
        clock: () => DateTime.utc(2026, 7, 26),
      );
      final application = await CognoteApplication.bootstrap(
        databaseFactory: () => CognoteDatabase(NativeDatabase.memory()),
        identityInitializer: (_) async => _identity('custom'),
        assetStorage: counting,
      );
      try {
        expect(counting.reconcileCalls, 0);
        final command = await application.createImageObservation.prepare(
          source: MemoryImageSource(_png()),
          capturedAtUtc: DateTime.utc(2026, 7, 26),
          timezoneOffset: 0,
        );
        expect(counting.reconcileCalls, 1);
        expect(command.preparedUri, startsWith('prepared/'));
      } finally {
        await application.close();
      }
    },
  );

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
      assetStorage: storage(),
    );

    expect(initializationCount, 1);
    expect(application.localIdentity, same(expectedIdentity));
    await application.close();
  });

  test('real database bootstrap creates only one local identity', () async {
    final database = CognoteDatabase(NativeDatabase.memory());
    final application = await CognoteApplication.bootstrap(
      databaseFactory: () => database,
      assetStorage: storage(),
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
      final firstRoot = Directory('${directory.path}/assets-1')
        ..createSync(recursive: true);
      final secondRoot = Directory('${directory.path}/assets-2')
        ..createSync(recursive: true);

      final first = await CognoteApplication.bootstrap(
        databaseFactory: () => CognoteDatabase.open(directory: directory),
        assetStorage: FileAssetStorage(
          root: firstRoot,
          clock: () => DateTime.utc(2026, 7, 26),
        ),
      );
      final firstIdentity = first.localIdentity;
      await first.close();

      final second = await CognoteApplication.bootstrap(
        databaseFactory: () => CognoteDatabase.open(directory: directory),
        assetStorage: FileAssetStorage(
          root: secondRoot,
          clock: () => DateTime.utc(2026, 7, 26),
        ),
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
          assetStorage: storage(),
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
      assetStorage: storage(),
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
      assetStorage: storage(),
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
      assetStorage: storage(),
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

Uint8List _png() =>
    Uint8List.fromList(img.encodePng(img.Image(width: 1, height: 1)));

class _CountingAssetStorage extends FileAssetStorage {
  _CountingAssetStorage({required super.root, required super.clock});
  var reconcileCalls = 0;

  @override
  Future<void> reconcile(ObservationRepository repository) async {
    reconcileCalls++;
    await super.reconcile(repository);
  }
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
