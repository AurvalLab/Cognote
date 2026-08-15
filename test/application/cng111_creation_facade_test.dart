import 'dart:convert';
import 'dart:io';

import 'package:cognote/src/application/cognote_application.dart';
import 'package:cognote/src/database/cognote_database.dart';
import 'package:cognote/src/observation/data/file_asset_storage.dart';
import 'package:cognote/src/observation/domain/image_observation_exceptions.dart';
import 'package:cognote/src/observation/domain/observation_id_generator.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late Directory root;
  late CognoteApplication application;

  setUp(() async {
    root = await Directory.systemTemp.createTemp('cng111_facade_');
    application = await CognoteApplication.bootstrap(
      databaseFactory: () => CognoteDatabase(NativeDatabase.memory()),
      observationIdGenerator: _SequenceIdGenerator(),
      localAssetIdGenerator: _SequenceIdGenerator(start: 100),
      utcNow: () => DateTime.utc(2026, 8, 15, 4),
      assetStorage: FileAssetStorage(
        root: Directory('${root.path}/assets'),
        clock: () => DateTime.utc(2026, 8, 15, 4),
      ),
    );
  });

  tearDown(() async {
    await application.close();
    if (await root.exists()) await root.delete(recursive: true);
  });

  test(
    'temporary image facade creates through the real local pipeline',
    () async {
      final temporary = File('${root.path}/picked.png');
      await temporary.writeAsBytes(_pngBytes);

      final command = await application
          .prepareImageObservationFromTemporaryFile(
            file: temporary,
            declaredMimeType: 'image/png',
            caption: '临时图片',
            timezoneOffset: 480,
          );
      expect(await temporary.exists(), isFalse);

      final aggregate = await application.createPreparedImageObservation(
        command,
      );
      final detail = await application.getObservationDetail(
        aggregate.observation.id,
      );
      final outbox = await application.listPendingOutbox();

      expect(detail?.observation.rawText, '临时图片');
      expect(detail?.localAsset?.mimeType, 'image/png');
      expect(outbox, hasLength(1));
      expect(outbox.single.aggregateId, aggregate.observation.id);
    },
  );

  test(
    'temporary image facade cleans its cache file after validation failure',
    () async {
      final temporary = File('${root.path}/broken.png');
      await temporary.writeAsBytes([1, 2, 3, 4]);

      await expectLater(
        application.prepareImageObservationFromTemporaryFile(
          file: temporary,
          declaredMimeType: 'image/png',
          timezoneOffset: 480,
        ),
        throwsA(isA<UnsupportedImageException>()),
      );
      expect(await temporary.exists(), isFalse);
      expect(await application.listPendingOutbox(), isEmpty);
    },
  );
}

final _pngBytes = base64Decode(
  'iVBORw0KGgoAAAANSUhEUgAAAAIAAAACCAYAAABytg0kAAAAEUlEQVR4nGP4z8DwH4QZYAwAR8oH+WdZbrcAAAAASUVORK5CYII=',
);

class _SequenceIdGenerator implements ObservationIdGenerator {
  _SequenceIdGenerator({int start = 0}) : _next = start;

  int _next;

  @override
  String generate() {
    final suffix = (++_next).toString().padLeft(12, '0');
    return '018f9999-9999-7999-8999-$suffix';
  }
}
