import 'dart:io';
import 'dart:typed_data';

import 'package:cognote/src/identity/domain/device_identity.dart';
import 'package:cognote/src/identity/domain/identity_repository.dart';
import 'package:cognote/src/identity/domain/principal.dart';
import 'package:cognote/src/observation/application/create_image_observation.dart';
import 'package:cognote/src/observation/data/file_asset_storage.dart';
import 'package:cognote/src/observation/domain/image_source.dart';
import 'package:cognote/src/observation/domain/observation.dart';
import 'package:cognote/src/observation/domain/observation_id_generator.dart';
import 'package:cognote/src/observation/domain/observation_mutation_outcome.dart';
import 'package:cognote/src/observation/domain/observation_outbox_mutation_repository.dart';
import 'package:cognote/src/observation/domain/observation_repository.dart';
import 'package:cognote/src/outbox/domain/outbox_operation.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late Directory root;
  late FileAssetStorage storage;
  setUp(() async {
    root = await Directory.systemTemp.createTemp('cng104_execute_');
    storage = FileAssetStorage(root: root, clock: () => _now);
  });
  tearDown(() async {
    if (await root.exists()) await root.delete(recursive: true);
  });

  test('prepared exists and final missing moves then commits', () async {
    final command = await _command(storage);
    final repository = _Repository();
    final result = await _useCase(storage, repository).execute(command);
    expect(result.localAsset.localUri, command.finalUri);
    expect(await storage.exists(command.preparedUri), isFalse);
    expect(await storage.exists(command.finalUri), isTrue);
    expect(repository.operation?.ownerId, 'principal');
    expect(repository.operation?.deviceId, 'device');
    expect(repository.operation?.operationId, command.operationId);
    expect(repository.operation?.aggregateId, command.observationId);
    expect(repository.operation?.operationKind, 'observation_upsert');
    expect(repository.operation?.createdAt, command.createdAt);
    expect(repository.stored?.observation.id, command.observationId);
    expect(repository.stored?.localAsset.id, command.localAssetId);
  });

  test(
    'matching final is reused but differing final conflicts without overwrite',
    () async {
      final command = await _command(storage);
      await storage.move(command.preparedUri, command.finalUri);
      await _useCase(storage, _Repository()).execute(command);
      expect(await _hash(storage, command.finalUri), command.sha256);

      final second = await _command(storage);
      await storage.delete(second.finalUri);
      await storage.move(second.preparedUri, second.finalUri);
      final file = File('${root.path}/${second.finalUri}');
      await file.writeAsBytes([9, 9, 9]);
      await expectLater(
        _useCase(storage, _Repository()).execute(second),
        throwsA(isA<AssetDestinationConflictException>()),
      );
      expect(await file.readAsBytes(), [9, 9, 9]);
    },
  );

  test('existing DB requires a complete matching final', () async {
    final command = await _command(storage);
    await storage.move(command.preparedUri, command.finalUri);
    final repository = _Repository();
    final first = await _useCase(storage, repository).execute(command);
    final second = await _useCase(storage, repository).execute(command);
    expect(second.observation.createdAt, first.observation.createdAt);
    await storage.delete(command.finalUri);
    await expectLater(
      _useCase(storage, repository).execute(command),
      throwsA(isA<AssetIntegrityException>()),
    );
  });

  test('existing DB validates observation and local asset semantics', () async {
    final command = await _command(storage);
    await storage.move(command.preparedUri, command.finalUri);
    final repository = _SemanticRepository();
    final first = await _useCase(storage, repository).execute(command);
    final retry = await _useCase(storage, repository).execute(command);
    expect(retry.observation.createdAt, first.observation.createdAt);
    expect(repository.createCalls, 2);

    await expectLater(
      _useCase(
        storage,
        repository,
      ).execute(_copyCommand(command, caption: 'different')),
      throwsA(isA<ObservationIdConflictException>()),
    );
    await expectLater(
      _useCase(
        storage,
        repository,
      ).execute(_copyCommand(command, bytes: command.bytes + 1)),
      throwsA(isA<LocalAssetIdConflictException>()),
    );
  });

  test('missing prepared and final is an integrity failure', () async {
    final command = await _command(storage);
    await storage.delete(command.preparedUri);
    await expectLater(
      _useCase(storage, _Repository()).execute(command),
      throwsA(isA<AssetIntegrityException>()),
    );
  });

  test(
    'DB failure moves final back to prepared and preserves primary error',
    () async {
      final command = await _command(storage);
      final error = StateError('database failed');
      await expectLater(
        _useCase(storage, _Repository(createError: error)).execute(command),
        throwsA(same(error)),
      );
      expect(await storage.exists(command.preparedUri), isTrue);
      expect(await storage.exists(command.finalUri), isFalse);
    },
  );

  test('failed rollback preserves final and reports both errors', () async {
    final storage = _SecondMoveFailingStorage(root: root, clock: () => _now);
    final command = await _command(storage);
    final primary = StateError('database failed');
    try {
      await _useCase(
        storage,
        _Repository(createError: primary),
      ).execute(command);
      fail('expected compensation failure');
    } on ImagePersistenceCompensationException catch (error) {
      expect(error.persistenceError, same(primary));
      expect(error.compensationError, isA<ImageStorageException>());
    }
    expect(await storage.exists(command.finalUri), isTrue);
  });
}

Future<PreparedImageObservationCommand> _command(
  FileAssetStorage storage,
) async {
  const bytes = <int>[255, 216, 255, 217];
  const prepared = 'prepared/asset.jpg';
  await storage.copyToPrepared(
    MemoryImageSource(Uint8List.fromList(bytes)),
    prepared,
  );
  return PreparedImageObservationCommand(
    observationId: '018f7777-7777-7777-8777-777777777777',
    localAssetId: '018f8888-8888-7888-8888-888888888888',
    operationId: '018f9999-9999-7999-8999-999999999999',
    caption: null,
    capturedAtUtc: _now,
    createdAt: _now,
    timezoneOffset: 0,
    preparedUri: prepared,
    finalUri: 'originals/01/asset.jpg',
    mimeType: 'image/jpeg',
    bytes: bytes.length,
    width: 1,
    height: 1,
    sha256: sha256.convert(bytes).toString(),
  );
}

PreparedImageObservationCommand _copyCommand(
  PreparedImageObservationCommand source, {
  String? caption,
  String? mimeType,
  int? bytes,
}) => PreparedImageObservationCommand(
  observationId: source.observationId,
  localAssetId: source.localAssetId,
  operationId: source.operationId,
  caption: caption ?? source.caption,
  capturedAtUtc: source.capturedAtUtc,
  createdAt: source.createdAt,
  timezoneOffset: source.timezoneOffset,
  preparedUri: source.preparedUri,
  finalUri: source.finalUri,
  mimeType: mimeType ?? source.mimeType,
  bytes: bytes ?? source.bytes,
  width: source.width,
  height: source.height,
  sha256: source.sha256,
);

CreateImageObservation _useCase(
  FileAssetStorage storage,
  ObservationRepository repository,
) => CreateImageObservation(
  repository: repository,
  outboxMutationRepository: repository as ObservationOutboxMutationRepository,
  localIdentity: _identity(),
  observationIdGenerator: const _FixedId(),
  localAssetIdGenerator: const _FixedId(),
  assetStorage: storage,
  clock: () => _now,
);
Future<String> _hash(FileAssetStorage storage, String uri) async =>
    (await sha256.bind(storage.openRead(uri)).first).toString();
final _now = DateTime.utc(2026, 7, 26);

class _Repository
    implements ObservationRepository, ObservationOutboxMutationRepository {
  _Repository({this.createError});
  final Object? createError;
  ImageObservationAggregate? stored;
  OutboxOperation? operation;
  @override
  Future<ImageObservationAggregate> createImageWithOutbox({
    required ImageObservationAggregate aggregate,
    required OutboxOperation operation,
  }) async {
    if (createError != null) throw createError!;
    this.operation = operation;
    return stored ??= aggregate;
  }

  @override
  Future<ImageObservationAggregate?> findImageByObservationId(
    String id,
  ) async => stored?.observation.id == id ? stored : null;
  @override
  Future<bool> isLocalUriReferenced(String localUri) async =>
      stored?.localAsset.localUri == localUri;

  @override
  Future<Observation> create(Observation observation) =>
      throw UnimplementedError();

  @override
  Future<ImageObservationAggregate> createImage(
    ImageObservationAggregate aggregate,
  ) => throw UnimplementedError();

  @override
  Future<ObservationMutationOutcome> deleteObservation({
    required String ownerId,
    required String observationId,
    required DateTime deletedAt,
  }) => throw UnimplementedError();

  @override
  Future<ObservationMutationOutcome> restoreObservation({
    required String ownerId,
    required String observationId,
    required DateTime restoredAt,
  }) => throw UnimplementedError();

  @override
  Future<Observation> createTextWithOutbox({
    required Observation observation,
    required OutboxOperation operation,
  }) => throw UnimplementedError();

  @override
  Future<ObservationMutationOutcome> deleteWithOutbox({
    required String ownerId,
    required String observationId,
    required DateTime deletedAt,
    required OutboxOperation operation,
  }) => throw UnimplementedError();

  @override
  Future<ObservationMutationOutcome> restoreWithOutbox({
    required String ownerId,
    required String observationId,
    required DateTime restoredAt,
    required OutboxOperation operation,
  }) => throw UnimplementedError();
}

class _SemanticRepository extends _Repository {
  var createCalls = 0;

  @override
  Future<ImageObservationAggregate> createImageWithOutbox({
    required ImageObservationAggregate aggregate,
    required OutboxOperation operation,
  }) async {
    createCalls++;
    this.operation = operation;
    final existing = stored;
    if (existing == null) return stored = aggregate;
    if (existing.observation.rawText != aggregate.observation.rawText) {
      throw ObservationIdConflictException();
    }
    if (existing.localAsset.mimeType != aggregate.localAsset.mimeType ||
        existing.localAsset.bytes != aggregate.localAsset.bytes) {
      throw LocalAssetIdConflictException();
    }
    return existing;
  }
}

class _SecondMoveFailingStorage extends FileAssetStorage {
  _SecondMoveFailingStorage({required super.root, required super.clock});
  var moves = 0;
  @override
  Future<void> move(String fromUri, String toUri) async {
    moves++;
    if (moves == 2) throw ImageStorageException(StateError('rollback failed'));
    return super.move(fromUri, toUri);
  }
}

class _FixedId implements ObservationIdGenerator {
  const _FixedId();
  @override
  String generate() => '018f7777-7777-7777-8777-777777777777';
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
