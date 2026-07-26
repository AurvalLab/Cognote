import 'dart:io';
import 'dart:typed_data';

import 'package:cognote/src/identity/domain/device_identity.dart';
import 'package:cognote/src/identity/domain/identity_repository.dart';
import 'package:cognote/src/identity/domain/principal.dart';
import 'package:cognote/src/observation/application/create_image_observation.dart';
import 'package:cognote/src/observation/data/file_asset_storage.dart';
import 'package:cognote/src/observation/domain/image_source.dart';
import 'package:cognote/src/observation/domain/observation_id_generator.dart';
import 'package:cognote/src/observation/domain/observation_repository.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;

void main() {
  late Directory root;
  late FileAssetStorage storage;
  late CreateImageObservation useCase;

  setUp(() async {
    root = await Directory.systemTemp.createTemp('cng104_prepare_');
    storage = FileAssetStorage(root: root, clock: () => _now);
    useCase = CreateImageObservation(
      repository: _UnusedRepository(),
      localIdentity: _identity(),
      observationIdGenerator: const _FixedId(_observationId),
      localAssetIdGenerator: const _FixedId(_assetId),
      assetStorage: storage,
      clock: () => _now,
    );
  });

  tearDown(() async {
    if (await root.exists()) await root.delete(recursive: true);
  });

  test(
    'prepares stable ids, normalized caption, paths, bytes and hash',
    () async {
      final bytes = Uint8List.fromList(
        img.encodeJpg(img.Image(width: 2, height: 3)),
      );
      final command = await useCase.prepare(
        source: MemoryImageSource(bytes, declaredMimeType: 'image/jpeg'),
        caption: '  原样保留  ',
        capturedAtUtc: _capturedAt,
        timezoneOffset: 480,
      );

      expect(command.observationId, _observationId);
      expect(command.localAssetId, _assetId);
      expect(command.caption, '  原样保留  ');
      expect(command.capturedAtUtc, _capturedAt);
      expect(command.mimeType, 'image/jpeg');
      expect(command.width, 2);
      expect(command.height, 3);
      expect(command.bytes, bytes.length);
      expect(
        command.sha256,
        '8bb3cabc69bd676677116fb9a26bd3c931229db76d26416821a3297f492721fa',
      );
      expect(command.preparedUri, 'prepared/$_assetId.jpg');
      expect(
        command.finalUri,
        'originals/${_assetId.substring(0, 2)}/$_assetId.jpg',
      );
      expect(command.preparedUri, isNot(contains('..')));
      expect(command.finalUri, isNot(contains('..')));
      expect(
        File('${root.path}/${command.preparedUri}').lengthSync(),
        bytes.length,
      );
      expect(
        sha256
            .convert(
              File('${root.path}/${command.preparedUri}').readAsBytesSync(),
            )
            .toString(),
        command.sha256,
      );
    },
  );

  test('normalizes null and whitespace captions to null', () async {
    for (final caption in <String?>[null, ' \n\t ']) {
      final command = await useCase.prepare(
        source: MemoryImageSource(_png()),
        caption: caption,
        capturedAtUtc: _capturedAt,
        timezoneOffset: 0,
      );
      expect(command.caption, isNull);
      await storage.delete(command.preparedUri);
    }
  });

  test('every prepare executes reconciliation', () async {
    final countingStorage = _CountingStorage(root: root, clock: () => _now);
    final countingUseCase = _imageUseCase(
      storage: countingStorage,
      repository: _ReferenceRepository(),
    );
    final first = await countingUseCase.prepare(
      source: MemoryImageSource(_png()),
      capturedAtUtc: _capturedAt,
      timezoneOffset: 0,
    );
    await countingStorage.delete(first.preparedUri);
    final second = await countingUseCase.prepare(
      source: MemoryImageSource(_png()),
      capturedAtUtc: _capturedAt,
      timezoneOffset: 0,
    );
    await countingStorage.delete(second.preparedUri);
    expect(countingStorage.reconcileCalls, 2);
  });

  test(
    'second prepare removes an orphan created after the first scan',
    () async {
      final scanningUseCase = _imageUseCase(
        storage: storage,
        repository: _ReferenceRepository(),
      );
      final first = await scanningUseCase.prepare(
        source: MemoryImageSource(_png()),
        capturedAtUtc: _capturedAt,
        timezoneOffset: 0,
      );
      await storage.delete(first.preparedUri);
      final orphan = File('${root.path}/originals/01/orphan.jpg');
      await orphan.parent.create(recursive: true);
      await orphan.writeAsBytes([1]);
      await orphan.setLastModified(_now.subtract(const Duration(hours: 25)));

      await scanningUseCase.prepare(
        source: MemoryImageSource(_png()),
        capturedAtUtc: _capturedAt,
        timezoneOffset: 0,
      );

      expect(orphan.existsSync(), isFalse);
    },
  );

  test('reconciliation failure throws before staging is created', () async {
    final orphan = File('${root.path}/originals/01/orphan.jpg');
    await orphan.parent.create(recursive: true);
    await orphan.writeAsBytes([1]);
    await orphan.setLastModified(_now.subtract(const Duration(hours: 25)));
    final failingUseCase = _imageUseCase(
      storage: storage,
      repository: _ReferenceRepository(failQueries: true),
    );

    await expectLater(
      failingUseCase.prepare(
        source: MemoryImageSource(_png()),
        capturedAtUtc: _capturedAt,
        timezoneOffset: 0,
      ),
      throwsA(isA<ImageStorageException>()),
    );

    expect(Directory('${root.path}/staging').existsSync(), isFalse);
    expect(Directory('${root.path}/prepared').existsSync(), isFalse);
  });

  test('accepts JPEG, PNG, and static WebP', () async {
    final inputs = <(Uint8List, String)>[
      (
        Uint8List.fromList(img.encodeJpg(img.Image(width: 1, height: 1))),
        'image/jpeg',
      ),
      (_png(), 'image/png'),
      (_staticWebp, 'image/webp'),
    ];
    for (final input in inputs) {
      final command = await useCase.prepare(
        source: MemoryImageSource(input.$1, declaredMimeType: input.$2),
        capturedAtUtc: _capturedAt,
        timezoneOffset: 0,
      );
      expect(command.mimeType, input.$2);
      await storage.delete(command.preparedUri);
    }
  });

  test('rejects invalid time and timezone boundaries correctly', () async {
    for (final offset in [-840, 840]) {
      final command = await useCase.prepare(
        source: MemoryImageSource(_png()),
        capturedAtUtc: _capturedAt,
        timezoneOffset: offset,
      );
      expect(command.timezoneOffset, offset);
      await storage.delete(command.preparedUri);
    }
    for (final offset in [-841, 841]) {
      expect(
        () => useCase.prepare(
          source: MemoryImageSource(_png()),
          capturedAtUtc: _capturedAt,
          timezoneOffset: offset,
        ),
        throwsA(isA<InvalidTimezoneOffsetException>()),
      );
    }
    expect(
      () => useCase.prepare(
        source: MemoryImageSource(_png()),
        capturedAtUtc: DateTime(2026),
        timezoneOffset: 0,
      ),
      throwsA(isA<InvalidCapturedAtException>()),
    );
  });

  test('accepts frozen pixel and single-edge limits', () {
    expect(
      () => validateImageDimensions(width: 10000, height: 5000),
      returnsNormally,
    );
    expect(
      () => validateImageDimensions(width: 16384, height: 1),
      returnsNormally,
    );
    expect(
      () => validateImageDimensions(width: 1, height: 16384),
      returnsNormally,
    );
  });

  test('rejects dimensions beyond frozen pixel and edge limits', () {
    // 3,561 × 14,041 = 50,000,001 pixels.
    expect(
      () => validateImageDimensions(width: 3561, height: 14041),
      throwsA(isA<InvalidImageDimensionsException>()),
    );
    expect(
      () => validateImageDimensions(width: 10001, height: 5000),
      throwsA(isA<InvalidImageDimensionsException>()),
    );
    expect(
      () => validateImageDimensions(width: 16385, height: 1),
      throwsA(isA<InvalidImageDimensionsException>()),
    );
    expect(
      () => validateImageDimensions(width: 1, height: 16385),
      throwsA(isA<InvalidImageDimensionsException>()),
    );
  });

  test(
    'rejects empty, oversized, corrupt, MIME-conflicting and animated images',
    () async {
      final cases = <(ImageSource, Type)>[
        (MemoryImageSource(Uint8List(0)), ImageSourceNotReadableException),
        (
          MemoryImageSource(Uint8List(25 * 1024 * 1024 + 1)),
          ImageTooLargeException,
        ),
        (
          MemoryImageSource(Uint8List.fromList([1, 2, 3])),
          UnsupportedImageException,
        ),
        (
          MemoryImageSource(_png(), declaredMimeType: 'image/jpeg'),
          UnsupportedImageException,
        ),
        (MemoryImageSource(_gif), UnsupportedImageException),
        (MemoryImageSource(_animatedWebp), UnsupportedImageException),
      ];
      for (final item in cases) {
        await expectLater(
          useCase.prepare(
            source: item.$1,
            capturedAtUtc: _capturedAt,
            timezoneOffset: 0,
          ),
          throwsA(predicate((error) => error.runtimeType == item.$2)),
        );
      }
    },
  );
}

Uint8List _png() =>
    Uint8List.fromList(img.encodePng(img.Image(width: 2, height: 2)));
final _gif = Uint8List.fromList('GIF89a'.codeUnits);
final _animatedWebp = Uint8List.fromList('RIFF0000WEBPANIM'.codeUnits);
final _staticWebp = Uint8List.fromList(
  img.encodeWebP(img.Image(width: 1, height: 1)),
);
const _observationId = '018f7777-7777-7777-8777-777777777777';
const _assetId = '018f8888-8888-7888-8888-888888888888';
final _now = DateTime.utc(2026, 7, 26, 10);
final _capturedAt = DateTime.utc(2026, 7, 25, 9);

class _FixedId implements ObservationIdGenerator {
  const _FixedId(this.value);
  final String value;
  @override
  String generate() => value;
}

CreateImageObservation _imageUseCase({
  required FileAssetStorage storage,
  required ObservationRepository repository,
}) => CreateImageObservation(
  repository: repository,
  localIdentity: _identity(),
  observationIdGenerator: const _FixedId(_observationId),
  localAssetIdGenerator: const _FixedId(_assetId),
  assetStorage: storage,
  clock: () => _now,
);

class _CountingStorage extends FileAssetStorage {
  _CountingStorage({required super.root, required super.clock});
  var reconcileCalls = 0;

  @override
  Future<void> reconcile(ObservationRepository repository) async {
    reconcileCalls++;
    await super.reconcile(repository);
  }
}

class _ReferenceRepository implements ObservationRepository {
  _ReferenceRepository({this.failQueries = false});
  final bool failQueries;

  @override
  Future<bool> isLocalUriReferenced(String localUri) async {
    if (failQueries) throw StateError('database unavailable');
    return false;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _UnusedRepository implements ObservationRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

LocalIdentity _identity() => LocalIdentity(
  principal: Principal(
    id: 'principal-1',
    kind: PrincipalKind.anonymous,
    status: PrincipalStatus.active,
    homeRegion: 'cn-mainland',
    dataResidency: 'cn',
    createdAt: _now,
    upgradedAt: null,
  ),
  device: DeviceIdentity(
    id: 'device-1',
    principalId: 'principal-1',
    publicInstallId: 'install-1',
    createdAt: _now,
    lastSeenAt: _now,
  ),
);
