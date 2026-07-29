import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:cognote/src/application/cognote_application.dart';
import 'package:cognote/src/observation/domain/image_source.dart';
import 'package:cognote/src/observation/domain/observation_id_generator.dart';
import 'package:cognote/src/observation/domain/observation_mutation_outcome.dart';
import 'package:cognote/src/outbox/domain/outbox_operation.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:path_provider/path_provider.dart';

const _runId = String.fromEnvironment('CNG109_RUN_ID');
const _artifactDir = String.fromEnvironment('CNG109_ARTIFACT_DIR');
const _metadataDirectory = 'cng109';
const _deviceArtifactProtocol = 'application-support-export-via-run-as';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('prepares isolated O3 state for E5 recovery', (_) async {
    expect(_runId, isNotEmpty);
    expect(_artifactDir, isNotEmpty);
    final ids = _Ids();
    final application = await CognoteApplication.bootstrap(
      observationIdGenerator: ids,
      localAssetIdGenerator: ids,
      utcNow: _utcNow,
    );
    try {
      final restored = application.prepareTextObservation(
        rawText: '$_runId restored',
        timezoneOffset: 0,
      );
      final tombstone = application.prepareTextObservation(
        rawText: '$_runId tombstone',
        timezoneOffset: 0,
      );
      final source = _pngBytes();
      final image = await application.createImageObservation.prepare(
        source: MemoryImageSource(source, declaredMimeType: 'image/png'),
        caption: '$_runId image',
        timezoneOffset: 0,
      );

      await application.createTextObservation(restored);
      await application.createTextObservation(tombstone);
      await application.createImageObservation.execute(image);

      expect(
        await application.deleteObservation(restored.observationId),
        ObservationMutationOutcome.changed,
      );
      expect(
        await application.restoreObservation(restored.observationId),
        ObservationMutationOutcome.changed,
      );
      expect(
        await application.deleteObservation(tombstone.observationId),
        ObservationMutationOutcome.changed,
      );

      await _expectActive(
        application,
        restored.observationId,
        '$_runId restored',
      );
      await _expectDeleted(
        application,
        tombstone.observationId,
        '$_runId tombstone',
      );
      await _expectActive(application, image.observationId, '$_runId image');

      final imageDetail = await application.getObservationDetail(
        image.observationId,
      );
      expect(imageDetail, isNotNull);
      final localAsset = imageDetail!.localAsset;
      expect(localAsset, isNotNull);
      final imageFile = application.resolveLocalAsset(localAsset!.localUri);
      expect(await imageFile.exists(), isTrue);
      final imageHash = sha256
          .convert(await imageFile.readAsBytes())
          .toString();
      final sourceHash = sha256.convert(source).toString();
      expect(imageHash, sourceHash);

      final outbox = await application.listPendingOutbox();
      expect(outbox, hasLength(6));
      _expectOutboxOrder(outbox);
      for (final operation in outbox) {
        expect(operation.ownerId, application.localIdentity.principal.id);
        expect(operation.deviceId, application.localIdentity.device.id);
      }
      _expectOperationKinds(outbox, restored.observationId, const [
        'observation_upsert',
        'observation_delete',
        'observation_upsert',
      ]);
      _expectOperationKinds(outbox, tombstone.observationId, const [
        'observation_upsert',
        'observation_delete',
      ]);
      _expectOperationKinds(outbox, image.observationId, const [
        'observation_upsert',
      ]);

      await _writeResult('prepare-result.json', {
        'runId': _runId,
        'artifactDir': _artifactDir,
        'deviceArtifactProtocol': _deviceArtifactProtocol,
        'identity': {
          'principalId': application.localIdentity.principal.id,
          'deviceId': application.localIdentity.device.id,
          'publicInstallId': application.localIdentity.device.publicInstallId,
        },
        'observations': {
          'restoredId': restored.observationId,
          'tombstoneId': tombstone.observationId,
          'imageId': image.observationId,
          'imageLocalUri': localAsset.localUri,
          'imageSha256': imageHash,
          'sourceSha256': sourceHash,
        },
        'outbox': outbox.map(_outboxJson).toList(),
      });
    } finally {
      await application.close();
    }
  });
}

Future<void> _expectActive(
  CognoteApplication application,
  String observationId,
  String marker,
) async {
  final timeline = await application.watchTimeline().first;
  expect(timeline.any((item) => item.id == observationId), isTrue);
  final detail = await application.getObservationDetail(observationId);
  expect(detail, isNotNull);
  expect(detail!.observation.deletedAt, isNull);
  final results = await application.watchSearch(marker).first;
  expect(results.any((item) => item.observation.id == observationId), isTrue);
  final deleted = await application.watchDeletedTimeline().first;
  expect(deleted.any((item) => item.id == observationId), isFalse);
}

Future<void> _expectDeleted(
  CognoteApplication application,
  String observationId,
  String marker,
) async {
  final timeline = await application.watchTimeline().first;
  expect(timeline.any((item) => item.id == observationId), isFalse);
  expect(await application.getObservationDetail(observationId), isNull);
  final results = await application.watchSearch(marker).first;
  expect(results.any((item) => item.observation.id == observationId), isFalse);
  final deleted = await application.watchDeletedTimeline().first;
  final observation = deleted.singleWhere((item) => item.id == observationId);
  expect(observation.deletedAt, isNotNull);
}

Future<void> _writeResult(String name, Map<String, Object?> value) async {
  final support = await getApplicationSupportDirectory();
  final directory = Directory('${support.path}/$_metadataDirectory/$_runId');
  await directory.create(recursive: true);
  await File('${directory.path}/$name').writeAsString(jsonEncode(value));
}

Map<String, Object?> _outboxJson(OutboxOperation value) => {
  'operationId': value.operationId,
  'ownerId': value.ownerId,
  'deviceId': value.deviceId,
  'aggregateType': value.aggregateType,
  'aggregateId': value.aggregateId,
  'operationKind': value.operationKind,
  'createdAt': value.createdAt.toIso8601String(),
};

void _expectOperationKinds(
  List<OutboxOperation> operations,
  String aggregateId,
  List<String> expected,
) {
  expect(
    operations
        .where((operation) => operation.aggregateId == aggregateId)
        .map((operation) => operation.operationKind),
    orderedEquals(expected),
  );
}

void _expectOutboxOrder(List<OutboxOperation> operations) {
  for (var index = 1; index < operations.length; index++) {
    final previous = operations[index - 1];
    final current = operations[index];
    final order = previous.createdAt.compareTo(current.createdAt);
    expect(
      order < 0 ||
          (order == 0 &&
              previous.operationId.compareTo(current.operationId) <= 0),
      isTrue,
    );
  }
}

Uint8List _pngBytes() => Uint8List.fromList(
  base64Decode(
    'iVBORw0KGgoAAAANSUhEUgAAAAIAAAACCAYAAABytg0kAAAAEUlEQVR4nGP4z8DwH4QZYAwAR8oH+WdZbrcAAAAASUVORK5CYII=',
  ),
);

class _Ids implements ObservationIdGenerator {
  var _value = 0;

  @override
  String generate() {
    _value++;
    return '018f0000-0000-7000-8000-${_value.toString().padLeft(12, '0')}';
  }
}

DateTime _utcNow() => DateTime.utc(2026, 7, 29, 6);
