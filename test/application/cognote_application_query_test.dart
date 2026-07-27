import 'dart:io';

import 'package:cognote/src/application/cognote_application.dart';
import 'package:cognote/src/database/cognote_database.dart';
import 'package:cognote/src/observation/data/file_asset_storage.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('application query APIs bind the initialized local owner', () async {
    final root = await Directory.systemTemp.createTemp('cng105_app_query_');
    final application = await CognoteApplication.bootstrap(
      databaseFactory: () => CognoteDatabase(NativeDatabase.memory()),
      assetStorage: FileAssetStorage(
        root: root,
        clock: () => DateTime.utc(2026, 7, 26),
      ),
    );
    try {
      final emissions = <List<dynamic>>[];
      final subscription = application.watchTimeline().listen(emissions.add);
      addTearDown(subscription.cancel);
      await _waitFor(() => emissions.isNotEmpty);
      expect(emissions.single, isEmpty);
      expect(await application.getObservationDetail('missing'), isNull);
    } finally {
      await application.close();
      if (await root.exists()) await root.delete(recursive: true);
    }
  });

  test(
    'application exposes owner-bound search and propagates database errors',
    () async {
      final root = await Directory.systemTemp.createTemp('cng107_app_search_');
      final application = await CognoteApplication.bootstrap(
        databaseFactory: () => CognoteDatabase(NativeDatabase.memory()),
        assetStorage: FileAssetStorage(
          root: root,
          clock: () => DateTime.utc(2026, 7, 26),
        ),
      );
      try {
        expect(await application.watchSearch('   ').first, isEmpty);
        await application.close();
        await expectLater(
          application.watchSearch('蓝雪花').first,
          throwsA(anything),
        );
      } finally {
        if (await root.exists()) await root.delete(recursive: true);
      }
    },
  );
}

Future<void> _waitFor(bool Function() condition) async {
  for (var attempt = 0; attempt < 100; attempt++) {
    if (condition()) return;
    await Future<void>.delayed(const Duration(milliseconds: 10));
  }
  fail('Timed out waiting for stream emission');
}
