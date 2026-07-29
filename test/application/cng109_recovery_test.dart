import 'dart:io';
import 'dart:typed_data';

import 'package:cognote/src/application/cognote_application.dart';
import 'package:cognote/src/database/cognote_database.dart'
    show CognoteDatabase;
import 'package:cognote/src/observation/data/file_asset_storage.dart';
import 'package:cognote/src/observation/domain/image_source.dart';
import 'package:cognote/src/observation/domain/observation.dart';
import 'package:cognote/src/observation/domain/observation_id_generator.dart';
import 'package:cognote/src/observation/domain/observation_mutation_outcome.dart';
import 'package:cognote/src/outbox/domain/outbox_operation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;

void main() {
  test('CNG-109 application close and rebuild restores local state', () async {
    final root = await Directory.systemTemp.createTemp('cng109_recovery_');
    final databaseDirectory = Directory('${root.path}/sqlite');
    final assetRoot = Directory('${root.path}/assets');
    final clock = _Clock();
    final ids = _Ids();
    final pngBytes = _png();
    CognoteApplication? first;
    CognoteApplication? second;

    try {
      first = await _bootstrap(
        databaseDirectory: databaseDirectory,
        assetRoot: assetRoot,
        clock: clock,
        ids: ids,
      );
      final firstIdentity = first.localIdentity;

      final restored = first.prepareTextObservation(
        rawText: 'A cng109_restored_record',
        timezoneOffset: 480,
      );
      final persistedTombstone = first.prepareTextObservation(
        rawText: 'B cng109_persisted_tombstone',
        timezoneOffset: 480,
      );
      final imageCommand = await first.createImageObservation.prepare(
        source: MemoryImageSource(pngBytes, declaredMimeType: 'image/png'),
        caption: 'C image',
        timezoneOffset: 480,
      );

      final restoredVisible = _timelineHas(first, restored.observationId);
      await first.createTextObservation(restored);
      await restoredVisible;
      final tombstoneVisible = _timelineHas(
        first,
        persistedTombstone.observationId,
      );
      await first.createTextObservation(persistedTombstone);
      await tombstoneVisible;
      final imageVisible = _timelineHas(first, imageCommand.observationId);
      await first.createImageObservation.execute(imageCommand);
      await imageVisible;

      await _expectActiveText(
        first,
        restored.observationId,
        'cng109_restored_record',
      );
      expect(
        await first.deleteObservation(restored.observationId),
        ObservationMutationOutcome.changed,
      );
      await _expectDeleted(
        first,
        restored.observationId,
        'cng109_restored_record',
      );
      expect(
        await first.restoreObservation(restored.observationId),
        ObservationMutationOutcome.changed,
      );
      await _expectActiveText(
        first,
        restored.observationId,
        'cng109_restored_record',
      );

      expect(
        await first.deleteObservation(persistedTombstone.observationId),
        ObservationMutationOutcome.changed,
      );
      await _expectDeleted(
        first,
        persistedTombstone.observationId,
        'cng109_persisted_tombstone',
      );

      final firstImage = await first.getObservationDetail(
        imageCommand.observationId,
      );
      expect(firstImage, isNotNull);
      final firstAsset = firstImage!.localAsset;
      expect(firstAsset, isNotNull);
      final firstImageFile = first.resolveLocalAsset(firstAsset!.localUri);
      expect(await firstImageFile.exists(), isTrue);
      final firstImageBytes = await firstImageFile.readAsBytes();
      expect(firstImageBytes, orderedEquals(pngBytes));

      final outboxBeforeRestart = await first.listPendingOutbox();
      for (final operation in outboxBeforeRestart) {
        expect(operation.ownerId, firstIdentity.principal.id);
        expect(operation.deviceId, firstIdentity.device.id);
      }
      _expectOutboxOrder(outboxBeforeRestart);
      expect(outboxBeforeRestart, hasLength(6));
      _expectOperationKinds(outboxBeforeRestart, restored.observationId, [
        'observation_upsert',
        'observation_delete',
        'observation_upsert',
      ]);
      _expectOperationKinds(
        outboxBeforeRestart,
        persistedTombstone.observationId,
        ['observation_upsert', 'observation_delete'],
      );
      _expectOperationKinds(outboxBeforeRestart, imageCommand.observationId, [
        'observation_upsert',
      ]);

      await first.close();
      first = null;

      second = await _bootstrap(
        databaseDirectory: databaseDirectory,
        assetRoot: assetRoot,
        clock: clock,
        ids: ids,
      );
      expect(second.localIdentity.principal.id, firstIdentity.principal.id);
      expect(second.localIdentity.device.id, firstIdentity.device.id);
      expect(
        second.localIdentity.device.publicInstallId,
        firstIdentity.device.publicInstallId,
      );

      await _expectActiveText(
        second,
        restored.observationId,
        'cng109_restored_record',
      );
      await _expectDeleted(
        second,
        persistedTombstone.observationId,
        'cng109_persisted_tombstone',
      );

      final secondImage = await second.getObservationDetail(
        imageCommand.observationId,
      );
      expect(secondImage, isNotNull);
      final secondAsset = secondImage!.localAsset;
      expect(secondAsset, isNotNull);
      final secondImageFile = second.resolveLocalAsset(secondAsset!.localUri);
      expect(await secondImageFile.exists(), isTrue);
      expect(
        await secondImageFile.readAsBytes(),
        orderedEquals(firstImageBytes),
      );

      final outboxAfterRestart = await second.listPendingOutbox();
      _expectOutboxEqual(outboxAfterRestart, outboxBeforeRestart);
      expect(
        await second.restoreObservation(restored.observationId),
        ObservationMutationOutcome.unchanged,
      );
      _expectOutboxEqual(await second.listPendingOutbox(), outboxAfterRestart);
    } finally {
      await first?.close();
      await second?.close();
      if (await root.exists()) await root.delete(recursive: true);
    }
  });
}

Future<CognoteApplication> _bootstrap({
  required Directory databaseDirectory,
  required Directory assetRoot,
  required _Clock clock,
  required _Ids ids,
}) => CognoteApplication.bootstrap(
  databaseFactory: () => CognoteDatabase.open(directory: databaseDirectory),
  assetStorage: FileAssetStorage(root: assetRoot, clock: clock.call),
  utcNow: clock.call,
  observationIdGenerator: ids,
  localAssetIdGenerator: ids,
);

Future<void> _expectActiveText(
  CognoteApplication application,
  String observationId,
  String marker,
) async {
  await _timelineHas(application, observationId);
  final detail = await application.getObservationDetail(observationId);
  expect(detail, isNotNull);
  expect(detail!.observation.deletedAt, isNull);
  expect(await _searchHas(application, marker, observationId), isTrue);
  expect(await _deletedHas(application, observationId), isFalse);
}

Future<void> _expectDeleted(
  CognoteApplication application,
  String observationId,
  String marker,
) async {
  await _timelineLacks(application, observationId);
  expect(await application.getObservationDetail(observationId), isNull);
  expect(await _searchHas(application, marker, observationId), isFalse);
  final deleted = await application.watchDeletedTimeline().firstWhere(
    (items) => items.any((item) => item.id == observationId),
  );
  expect(
    deleted.singleWhere((item) => item.id == observationId).deletedAt,
    isNotNull,
  );
}

Future<List<Observation>> _timelineHas(
  CognoteApplication application,
  String observationId,
) => application.watchTimeline().firstWhere(
  (items) => items.any((item) => item.id == observationId),
);

Future<List<Observation>> _timelineLacks(
  CognoteApplication application,
  String observationId,
) => application.watchTimeline().firstWhere(
  (items) => items.every((item) => item.id != observationId),
);

Future<bool> _deletedHas(
  CognoteApplication application,
  String observationId,
) => application.watchDeletedTimeline().first.then(
  (items) => items.any((item) => item.id == observationId),
);

Future<bool> _searchHas(
  CognoteApplication application,
  String marker,
  String observationId,
) => application
    .watchSearch(marker)
    .first
    .then((items) => items.any((item) => item.observation.id == observationId));

void _expectOperationKinds(
  List<OutboxOperation> operations,
  String aggregateId,
  List<String> kinds,
) => expect(
  operations
      .where((operation) => operation.aggregateId == aggregateId)
      .map((operation) => operation.operationKind),
  orderedEquals(kinds),
);

void _expectOutboxOrder(List<OutboxOperation> operations) {
  for (var index = 1; index < operations.length; index++) {
    final previous = operations[index - 1];
    final current = operations[index];
    final createdAtOrder = previous.createdAt.compareTo(current.createdAt);
    expect(
      createdAtOrder < 0 ||
          (createdAtOrder == 0 &&
              previous.operationId.compareTo(current.operationId) <= 0),
      isTrue,
    );
  }
}

void _expectOutboxEqual(
  List<OutboxOperation> actual,
  List<OutboxOperation> expected,
) {
  expect(actual, hasLength(expected.length));
  for (var index = 0; index < expected.length; index++) {
    final actualOperation = actual[index];
    final expectedOperation = expected[index];
    expect(actualOperation.operationId, expectedOperation.operationId);
    expect(actualOperation.ownerId, expectedOperation.ownerId);
    expect(actualOperation.deviceId, expectedOperation.deviceId);
    expect(actualOperation.aggregateType, expectedOperation.aggregateType);
    expect(actualOperation.aggregateId, expectedOperation.aggregateId);
    expect(actualOperation.operationKind, expectedOperation.operationKind);
    expect(actualOperation.createdAt, expectedOperation.createdAt);
  }
}

Uint8List _png() =>
    Uint8List.fromList(img.encodePng(img.Image(width: 2, height: 2)));

class _Clock {
  final _value = DateTime.utc(2026, 7, 29);

  DateTime call() => _value;
}

class _Ids implements ObservationIdGenerator {
  var _value = 0;

  @override
  String generate() {
    _value++;
    return '018f0000-0000-7000-8000-${_value.toString().padLeft(12, '0')}';
  }
}
