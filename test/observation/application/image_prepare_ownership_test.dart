import 'dart:async';
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
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;

void main() {
  late Directory root;
  setUp(
    () async =>
        root = await Directory.systemTemp.createTemp('cng104_ownership_'),
  );
  tearDown(() async {
    if (await root.exists()) await root.delete(recursive: true);
  });

  test(
    'external source is not cleaned and app-owned temporary is cleaned after success',
    () async {
      for (final ownership in ImageSourceOwnership.values) {
        var cleanups = 0;
        final source = MemoryImageSource(
          _png(),
          ownership: ownership,
          onCleanup: () async => cleanups++,
        );
        final useCase = _useCase(
          FileAssetStorage(root: root, clock: () => _now),
        );
        final command = await useCase.prepare(
          source: source,
          capturedAtUtc: _now,
          timezoneOffset: 0,
        );
        expect(cleanups, ownership == ImageSourceOwnership.external ? 0 : 1);
        expect(
          await File('${root.path}/${command.preparedUri}').exists(),
          isTrue,
        );
        await File('${root.path}/${command.preparedUri}').delete();
      }
    },
  );

  test(
    'prepare validation or decoding failure never cleans the source',
    () async {
      for (final source in [
        MemoryImageSource(
          _png(),
          ownership: ImageSourceOwnership.appOwnedTemporary,
          onCleanup: () async => fail('must not clean'),
        ),
        MemoryImageSource(
          Uint8List.fromList([1, 2, 3]),
          ownership: ImageSourceOwnership.appOwnedTemporary,
          onCleanup: () async => fail('must not clean'),
        ),
      ]) {
        await expectLater(
          _useCase(FileAssetStorage(root: root, clock: () => _now)).prepare(
            source: source,
            capturedAtUtc: source.bytes.length > 3 ? DateTime(2026) : _now,
            timezoneOffset: 0,
          ),
          throwsA(anything),
        );
      }
      expect(_allFiles(root), isEmpty);
    },
  );

  test(
    'copy stream failure removes staging and preserves source ownership',
    () async {
      var cleaned = false;
      final source = _ThrowingSource(() async => cleaned = true);
      await expectLater(
        _useCase(
          FileAssetStorage(root: root, clock: () => _now),
        ).prepare(source: source, capturedAtUtc: _now, timezoneOffset: 0),
        throwsA(isA<ImageStorageException>()),
      );
      expect(cleaned, isFalse);
      expect(_allFiles(root), isEmpty);
    },
  );

  test(
    'atomic rename failure returns no command and removes staging',
    () async {
      final storage = _RenameFailingStorage(root: root, clock: () => _now);
      await expectLater(
        _useCase(storage).prepare(
          source: MemoryImageSource(_png()),
          capturedAtUtc: _now,
          timezoneOffset: 0,
        ),
        throwsA(isA<ImageStorageException>()),
      );
      expect(_allFiles(root), isEmpty);
    },
  );

  test('storage rejects absolute and parent traversal paths', () async {
    final storage = FileAssetStorage(root: root, clock: () => _now);
    for (final unsafe in ['../outside.jpg', '${root.path}/outside.jpg']) {
      await expectLater(
        storage.delete(unsafe),
        throwsA(isA<ImageStorageException>()),
      );
    }
  });
}

CreateImageObservation _useCase(FileAssetStorage storage) =>
    CreateImageObservation(
      repository: _UnusedRepository(),
      localIdentity: _identity(),
      observationIdGenerator: const _FixedId(
        '018f7777-7777-7777-8777-777777777777',
      ),
      localAssetIdGenerator: const _FixedId(
        '018f8888-8888-7888-8888-888888888888',
      ),
      assetStorage: storage,
      clock: () => _now,
    );

List<FileSystemEntity> _allFiles(Directory root) => root.existsSync()
    ? root.listSync(recursive: true).whereType<File>().toList()
    : [];

Uint8List _png() =>
    Uint8List.fromList(img.encodePng(img.Image(width: 2, height: 2)));
final _now = DateTime.utc(2026, 7, 26);

class _ThrowingSource implements ImageSource {
  _ThrowingSource(this.onCleanup);
  final Future<void> Function() onCleanup;
  @override
  String? get declaredMimeType => null;
  @override
  ImageSourceOwnership get ownership => ImageSourceOwnership.appOwnedTemporary;
  @override
  Stream<List<int>> openRead() async* {
    yield [1, 2];
    throw StateError('copy failed');
  }

  @override
  Future<void> cleanup() => onCleanup();
}

class _RenameFailingStorage extends FileAssetStorage {
  _RenameFailingStorage({required super.root, required super.clock});
  @override
  Future<void> move(String fromUri, String toUri) =>
      throw ImageStorageException(StateError('rename failed'));
}

class _FixedId implements ObservationIdGenerator {
  const _FixedId(this.id);
  final String id;
  @override
  String generate() => id;
}

class _UnusedRepository implements ObservationRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

LocalIdentity _identity() => LocalIdentity(
  principal: Principal(
    id: 'principal',
    kind: PrincipalKind.anonymous,
    status: PrincipalStatus.active,
    homeRegion: 'cn-mainland',
    dataResidency: 'cn',
    createdAt: _now,
    upgradedAt: null,
  ),
  device: DeviceIdentity(
    id: 'device',
    principalId: 'principal',
    publicInstallId: 'install',
    createdAt: _now,
    lastSeenAt: _now,
  ),
);
