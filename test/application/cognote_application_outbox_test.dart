import 'dart:io';

import 'package:cognote/src/application/cognote_application.dart';
import 'package:cognote/src/database/cognote_database.dart';
import 'package:cognote/src/observation/data/file_asset_storage.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'application binds the local owner when listing pending outbox',
    () async {
      final root = await Directory.systemTemp.createTemp('cng108_application_');
      final database = CognoteDatabase(NativeDatabase.memory());
      final application = await CognoteApplication.bootstrap(
        databaseFactory: () => database,
        assetStorage: FileAssetStorage(
          root: root,
          clock: () => DateTime.utc(2026, 7, 28),
        ),
        utcNow: () => DateTime.utc(2026, 7, 28),
      );
      try {
        final command = application.prepareTextObservation(
          rawText: 'outbox',
          timezoneOffset: 480,
        );
        await application.createTextObservation(command);

        final pending = await application.listPendingOutbox();
        expect(pending, hasLength(1));
        expect(pending.single.ownerId, application.localIdentity.principal.id);
        expect(pending.single.deviceId, application.localIdentity.device.id);
        expect(pending.single.operationId, command.operationId);
        expect(pending.single.aggregateId, command.observationId);
        expect(pending.single.operationKind, 'observation_upsert');
        expect(pending.single.createdAt, command.createdAt);
      } finally {
        await application.close();
        await root.delete(recursive: true);
      }
    },
  );
}
