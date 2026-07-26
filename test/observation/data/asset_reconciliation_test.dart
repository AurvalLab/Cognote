import 'dart:io';

import 'package:cognote/src/observation/data/file_asset_storage.dart';
import 'package:cognote/src/observation/domain/observation_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late Directory root;
  late FileAssetStorage storage;
  setUp(() async {
    root = await Directory.systemTemp.createTemp('cng104_reconcile_');
    storage = FileAssetStorage(root: root, clock: () => _now);
  });
  tearDown(() async {
    if (await root.exists()) await root.delete(recursive: true);
  });

  test(
    'deletes stale staging and prepared but preserves fresh files',
    () async {
      final staleStaging = await _file(root, 'staging/stale.part', _old);
      final freshStaging = await _file(root, 'staging/fresh.part', _fresh);
      final stalePrepared = await _file(root, 'prepared/stale.jpg', _old);
      final freshPrepared = await _file(root, 'prepared/fresh.jpg', _fresh);
      await storage.reconcile(_References());
      expect(staleStaging.existsSync(), isFalse);
      expect(stalePrepared.existsSync(), isFalse);
      expect(freshStaging.existsSync(), isTrue);
      expect(freshPrepared.existsSync(), isTrue);
    },
  );

  test(
    'deletes stale unreferenced final and preserves referenced final',
    () async {
      final orphan = await _file(root, 'originals/01/orphan.jpg', _old);
      final kept = await _file(root, 'originals/01/kept.jpg', _old);
      await storage.reconcile(_References({'originals/01/kept.jpg'}));
      expect(orphan.existsSync(), isFalse);
      expect(kept.existsSync(), isTrue);
    },
  );

  test(
    'database lookup failure preserves all finals and fails reconciliation',
    () async {
      final finalFile = await _file(root, 'originals/01/final.jpg', _old);
      await expectLater(
        storage.reconcile(_References(const {}, true)),
        throwsA(anything),
      );
      expect(finalFile.existsSync(), isTrue);
    },
  );

  test('reconciliation failure blocks later prepare operations', () async {
    await _file(root, 'originals/01/final.jpg', _old);
    await expectLater(
      storage.reconcile(_References(const {}, true)),
      throwsA(anything),
    );
  });

  test(
    'stops after a later final lookup fails without rolling back prior deletion',
    () async {
      final first = await _file(root, 'originals/01/a-orphan.jpg', _old);
      final second = await _file(root, 'originals/01/b-fails.jpg', _old);
      final third = await _file(root, 'originals/01/c-unvisited.jpg', _old);
      final references = _OrderedFailureReferences('originals/01/b-fails.jpg');

      await expectLater(
        storage.reconcile(references),
        throwsA(isA<StateError>()),
      );

      expect(first.existsSync(), isFalse);
      expect(second.existsSync(), isTrue);
      expect(third.existsSync(), isTrue);
      expect(references.queries, [
        'originals/01/a-orphan.jpg',
        'originals/01/b-fails.jpg',
      ]);
    },
  );

  test('never touches files outside the configured asset root', () async {
    final outside = File(
      '${root.parent.path}/cng104-outside-${root.path.hashCode}.jpg',
    );
    await outside.writeAsBytes([1]);
    await outside.setLastModified(_old);
    try {
      await storage.reconcile(_References());
      expect(outside.existsSync(), isTrue);
    } finally {
      if (outside.existsSync()) await outside.delete();
    }
  });
}

Future<File> _file(Directory root, String relative, DateTime modified) async {
  final file = File('${root.path}/$relative');
  await file.parent.create(recursive: true);
  await file.writeAsBytes([1]);
  await file.setLastModified(modified);
  return file;
}

final _now = DateTime.utc(2026, 7, 26, 12);
final _old = _now.subtract(const Duration(hours: 25));
final _fresh = _now.subtract(const Duration(hours: 23));

class _OrderedFailureReferences implements ObservationRepository {
  _OrderedFailureReferences(this.failureUri);
  final String failureUri;
  final List<String> queries = [];

  @override
  Future<bool> isLocalUriReferenced(String localUri) async {
    queries.add(localUri);
    if (localUri == failureUri) throw StateError('database unavailable');
    return false;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _References implements ObservationRepository {
  _References([this.referenced = const {}, this.failQueries = false]);
  final Set<String> referenced;
  final bool failQueries;
  @override
  Future<bool> isLocalUriReferenced(String localUri) async {
    if (failQueries) throw StateError('database unavailable');
    return referenced.contains(localUri);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
