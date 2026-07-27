import 'dart:io';

import 'package:cognote/src/observation/data/file_asset_storage.dart';
import 'package:cognote/src/observation/domain/image_observation_exceptions.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as path;

void main() {
  late Directory root;
  late FileAssetStorage storage;

  setUp(() async {
    root = await Directory.systemTemp.createTemp('cng105_asset_read_');
    storage = FileAssetStorage(
      root: root,
      clock: () => DateTime.utc(2026, 7, 26),
    );
  });

  tearDown(() async {
    if (await root.exists()) await root.delete(recursive: true);
  });

  test('resolves a local uri inside the asset root without writing', () async {
    final existing = File(path.join(root.path, 'originals', '01', 'image.jpg'));
    await existing.parent.create(recursive: true);
    await existing.writeAsBytes([1, 2, 3]);
    final before = await root
        .list(recursive: true)
        .map((item) => item.path)
        .toList();

    final resolved = storage.resolveLocalFile('originals/01/image.jpg');

    expect(path.equals(resolved.path, existing.path), isTrue);
    expect(await resolved.exists(), isTrue);
    expect(await resolved.readAsBytes(), [1, 2, 3]);
    expect(
      await root.list(recursive: true).map((item) => item.path).toList(),
      before,
    );
  });

  test('missing local file remains missing after resolution', () async {
    final resolved = storage.resolveLocalFile('originals/01/missing.jpg');

    expect(await resolved.exists(), isFalse);
    expect(await root.list(recursive: true).toList(), isEmpty);
  });

  test('rejects absolute, traversal, and asset-root prefix escape paths', () {
    for (final uri in [
      path.join(root.path, 'outside.jpg'),
      r'C:\outside\image.jpg',
      '../outside.jpg',
      r'..\outside.jpg',
      'originals/../../outside.jpg',
      r'originals\01\..\..\outside.jpg',
      r'originals/01\..\..\outside.jpg',
      'originals/01/../../../${path.basename(root.path)}-outside/file.jpg',
    ]) {
      expect(
        () => storage.resolveLocalFile(uri),
        throwsA(isA<ImageStorageException>()),
        reason: uri,
      );
    }
  });
}
