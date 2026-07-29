import 'dart:convert';
import 'dart:io';

import 'package:cognote/src/application/cognote_application.dart';
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

  testWidgets('verifies E5 recovery after Android force-stop', (_) async {
    expect(_runId, isNotEmpty);
    expect(_artifactDir, isNotEmpty);
    final prepared = await _readResult('prepare-result.json');
    final application = await CognoteApplication.bootstrap();
    try {
      final identity = _map(prepared['identity']);
      expect(application.localIdentity.principal.id, identity['principalId']);
      expect(application.localIdentity.device.id, identity['deviceId']);
      expect(
        application.localIdentity.device.publicInstallId,
        identity['publicInstallId'],
      );

      final observations = _map(prepared['observations']);
      final restoredId = observations['restoredId']! as String;
      final tombstoneId = observations['tombstoneId']! as String;
      final imageId = observations['imageId']! as String;
      await _expectActive(application, restoredId, '$_runId restored');
      await _expectDeleted(application, tombstoneId, '$_runId tombstone');
      await _expectActive(application, imageId, '$_runId image');

      final imageDetail = await application.getObservationDetail(imageId);
      expect(imageDetail, isNotNull);
      final asset = imageDetail!.localAsset;
      expect(asset, isNotNull);
      final imageFile = application.resolveLocalAsset(asset!.localUri);
      expect(await imageFile.exists(), isTrue);
      final imageSha = sha256.convert(await imageFile.readAsBytes()).toString();
      expect(imageSha, observations['imageSha256']);
      expect(imageSha, observations['sourceSha256']);

      final before = await application.listPendingOutbox();
      _expectOutboxEqual(before, _list(prepared['outbox']));
      expect(
        await application.restoreObservation(restoredId),
        ObservationMutationOutcome.unchanged,
      );
      final after = await application.listPendingOutbox();
      _expectOutboxEqual(after, _list(prepared['outbox']));

      await _writeResult('verify-result.json', {
        'runId': _runId,
        'artifactDir': _artifactDir,
        'deviceArtifactProtocol': _deviceArtifactProtocol,
        'identity': {
          'principalId': application.localIdentity.principal.id,
          'deviceId': application.localIdentity.device.id,
          'publicInstallId': application.localIdentity.device.publicInstallId,
        },
        'imageSha256': imageSha,
        'outbox': after.map(_outboxJson).toList(),
        'idempotentRestore': 'unchanged',
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

Future<Map<String, dynamic>> _readResult(String name) async {
  final support = await getApplicationSupportDirectory();
  final file = File('${support.path}/$_metadataDirectory/$_runId/$name');
  return _map(jsonDecode(await file.readAsString()));
}

Future<void> _writeResult(String name, Map<String, Object?> value) async {
  final support = await getApplicationSupportDirectory();
  final directory = Directory('${support.path}/$_metadataDirectory/$_runId');
  await directory.create(recursive: true);
  await File('${directory.path}/$name').writeAsString(jsonEncode(value));
}

Map<String, dynamic> _map(Object? value) =>
    Map<String, dynamic>.from(value! as Map);

List<Map<String, dynamic>> _list(Object? value) => (value! as List)
    .map((item) => Map<String, dynamic>.from(item as Map))
    .toList();

void _expectOutboxEqual(
  List<OutboxOperation> actual,
  List<Map<String, dynamic>> expected,
) {
  expect(actual, hasLength(expected.length));
  for (var index = 0; index < expected.length; index++) {
    final operation = actual[index];
    final expectedOperation = expected[index];
    expect(operation.operationId, expectedOperation['operationId']);
    expect(operation.ownerId, expectedOperation['ownerId']);
    expect(operation.deviceId, expectedOperation['deviceId']);
    expect(operation.aggregateType, expectedOperation['aggregateType']);
    expect(operation.aggregateId, expectedOperation['aggregateId']);
    expect(operation.operationKind, expectedOperation['operationKind']);
    expect(
      operation.createdAt.toIso8601String(),
      expectedOperation['createdAt'],
    );
  }
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
