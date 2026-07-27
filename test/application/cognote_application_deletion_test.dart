import 'dart:io';

import 'package:cognote/src/application/cognote_application.dart';
import 'package:cognote/src/database/cognote_database.dart';
import 'package:cognote/src/observation/data/file_asset_storage.dart';
import 'package:cognote/src/observation/domain/observation_mutation_outcome.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'application mutations bind owner and use the injected UTC clock',
    () async {
      final root = await Directory.systemTemp.createTemp('cng106_app_');
      final database = CognoteDatabase(NativeDatabase.memory());
      var now = DateTime.utc(2026, 7, 28, 1);
      final application = await CognoteApplication.bootstrap(
        databaseFactory: () => database,
        utcNow: () => now,
        assetStorage: FileAssetStorage(root: root, clock: () => now),
      );
      try {
        final command = application.prepareTextObservation(
          rawText: '待删除',
          timezoneOffset: 480,
        );
        await application.createTextObservation(command);
        final active = <List<dynamic>>[];
        final deleted = <List<dynamic>>[];
        final activeSubscription = application.watchTimeline().listen(
          active.add,
        );
        final deletedSubscription = application.watchDeletedTimeline().listen(
          deleted.add,
        );
        addTearDown(activeSubscription.cancel);
        addTearDown(deletedSubscription.cancel);
        await _waitFor(() => active.isNotEmpty && deleted.isNotEmpty);

        now = DateTime.utc(2026, 7, 28, 2);
        expect(
          await application.deleteObservation(command.observationId),
          ObservationMutationOutcome.changed,
        );
        await _waitFor(() => deleted.last.isNotEmpty);
        expect(
          deleted.last.single.ownerId,
          application.localIdentity.principal.id,
        );
        expect(deleted.last.single.deletedAt, now);
        expect(deleted.last.single.updatedAt, now);
        expect(
          await application.deleteObservation(command.observationId),
          ObservationMutationOutcome.unchanged,
        );

        now = DateTime.utc(2026, 7, 28, 3);
        expect(
          await application.restoreObservation(command.observationId),
          ObservationMutationOutcome.changed,
        );
        await _waitFor(() => deleted.last.isEmpty && active.last.isNotEmpty);
        expect(active.last.single.deletedAt, isNull);
        expect(active.last.single.updatedAt, now);
        expect(
          await application.restoreObservation(command.observationId),
          ObservationMutationOutcome.unchanged,
        );
        expect(
          await application.deleteObservation('missing'),
          ObservationMutationOutcome.notFound,
        );
      } finally {
        await application.close();
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
