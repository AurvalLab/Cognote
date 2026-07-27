import 'package:cognote/src/database/cognote_database.dart' hide Observation;
import 'package:cognote/src/identity/application/initialize_local_identity.dart';
import 'package:cognote/src/identity/data/drift_identity_repository.dart';
import 'package:cognote/src/observation/data/drift_observation_repository.dart';
import 'package:cognote/src/observation/domain/observation.dart';
import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late CognoteDatabase database;
  late DriftObservationRepository repository;
  late String ownerId;
  late String deviceId;

  setUp(() async {
    database = CognoteDatabase(NativeDatabase.memory());
    final identity = await InitializeLocalIdentity(
      DriftIdentityRepository(database),
    )();
    ownerId = identity.principal.id;
    deviceId = identity.device.id;
    repository = DriftObservationRepository(database);
  });

  tearDown(() => database.close());

  test(
    'search filters owner and deleted records and supports long and short terms',
    () async {
      await repository.create(
        _observation('one', ownerId, deviceId, '蓝雪花 AI 观察', 1),
      );
      await repository.create(
        _observation('two', ownerId, deviceId, '其他内容', 2),
      );
      await _insertOtherOwner(database);
      await repository.create(
        _observation(
          'three',
          'other-owner',
          'device-other-owner',
          '蓝雪花 AI 观察',
          3,
        ),
      );
      await (database.update(database.observations)
            ..where((t) => t.id.equals('018f0000-0000-7000-8000-000000000001')))
          .write(
            ObservationsCompanion(deletedAt: Value(DateTime.utc(2026, 1, 1))),
          );

      expect(
        await repository
            .watchActiveSearch(ownerId: ownerId, query: '蓝雪花')
            .first,
        isEmpty,
      );
      expect(
        await repository.watchActiveSearch(ownerId: ownerId, query: 'AI').first,
        isEmpty,
      );

      await repository.restoreObservation(
        ownerId: ownerId,
        observationId: '018f0000-0000-7000-8000-000000000001',
        restoredAt: DateTime.utc(2026, 1, 2),
      );
      expect(
        (await repository
                .watchActiveSearch(ownerId: ownerId, query: '蓝雪花')
                .first)
            .map((result) => result.observation.id),
        ['018f0000-0000-7000-8000-000000000001'],
      );
      expect(
        (await repository
                .watchActiveSearch(ownerId: ownerId, query: 'AI')
                .first)
            .map((result) => result.observation.id),
        ['018f0000-0000-7000-8000-000000000001'],
      );
    },
  );

  test(
    'search stream re-emits after a matching observation is committed',
    () async {
      final values = <List<dynamic>>[];
      final subscription = repository
          .watchActiveSearch(ownerId: ownerId, query: '蓝雪花')
          .listen(values.add);
      addTearDown(subscription.cancel);
      await _waitFor(() => values.length == 1);

      await repository.create(_observation('one', ownerId, deviceId, '蓝雪花', 1));
      await _waitFor(() => values.length == 2);
      expect(
        values.last.single.observation.id,
        '018f0000-0000-7000-8000-000000000001',
      );
    },
  );

  test(
    'raw text trigger transitions keep exactly one indexed document',
    () async {
      await repository.create(_observation('one', ownerId, deviceId, '旧词', 1));
      await (database.update(database.observations)
            ..where((t) => t.id.equals('018f0000-0000-7000-8000-000000000001')))
          .write(const ObservationsCompanion(rawText: Value('新词')));
      expect(
        (await repository
            .watchActiveSearch(ownerId: ownerId, query: '旧词')
            .first),
        isEmpty,
      );
      expect(
        (await repository
            .watchActiveSearch(ownerId: ownerId, query: '新词')
            .first),
        hasLength(1),
      );

      await (database.update(database.observations)
            ..where((t) => t.id.equals('018f0000-0000-7000-8000-000000000001')))
          .write(const ObservationsCompanion(rawText: Value(null)));
      expect(
        (await repository
            .watchActiveSearch(ownerId: ownerId, query: '新词')
            .first),
        isEmpty,
      );
      final count = await database
          .customSelect(
            "SELECT COUNT(*) AS count FROM observation_search_fts WHERE observation_id = '018f0000-0000-7000-8000-000000000001'",
          )
          .getSingle();
      expect(count.read<int>('count'), 0);
    },
  );

  test(
    'empty queries return empty without touching a closed database',
    () async {
      await database.close();
      for (final query in ['', ' ', '\n\t']) {
        expect(
          await repository
              .watchActiveSearch(ownerId: ownerId, query: query)
              .first,
          isEmpty,
        );
      }
    },
  );

  test(
    'search handles operators, special text, mixed AND, null and ordering',
    () async {
      await repository.create(
        _observation('one', ownerId, deviceId, '蓝雪花 AI AND a"b %_ * : - ()', 1),
      );
      await repository.create(
        _observation('two', ownerId, deviceId, '蓝雪花 AI second', 2),
      );
      await repository.create(
        _observation('three', ownerId, deviceId, null, 3),
      );
      for (final query in ['AND', 'a"b', '%', '_', '*', ':', '-', '()']) {
        expect(
          await repository
              .watchActiveSearch(ownerId: ownerId, query: query)
              .first,
          isNotEmpty,
          reason: query,
        );
      }
      expect(
        (await repository
                .watchActiveSearch(ownerId: ownerId, query: '蓝雪花 AI')
                .first)
            .map((result) => result.observation.id),
        [
          '018f0000-0000-7000-8000-000000000002',
          '018f0000-0000-7000-8000-000000000001',
        ],
      );
      expect(
        await repository
            .watchActiveSearch(ownerId: ownerId, query: '蓝雪花 missing')
            .first,
        isEmpty,
      );
    },
  );

  test('search propagates database failures', () async {
    await database.close();
    await expectLater(
      repository.watchActiveSearch(ownerId: ownerId, query: '蓝雪花').first,
      throwsA(anything),
    );
  });

  test(
    'search reacts to updates, soft delete, restore and physical delete',
    () async {
      final emissions = <List<dynamic>>[];
      final subscription = repository
          .watchActiveSearch(ownerId: ownerId, query: '蓝雪花')
          .listen(emissions.add);
      addTearDown(subscription.cancel);
      await _waitFor(() => emissions.length == 1);
      final observation = _observation('one', ownerId, deviceId, '蓝雪花', 1);
      await repository.create(observation);
      await _waitFor(() => emissions.length >= 2 && emissions.last.length == 1);
      await (database.update(database.observations)
            ..where((t) => t.id.equals(observation.id)))
          .write(const ObservationsCompanion(rawText: Value('其他内容')));
      await _waitFor(() => emissions.last.isEmpty);
      await (database.update(database.observations)
            ..where((t) => t.id.equals(observation.id)))
          .write(const ObservationsCompanion(rawText: Value('蓝雪花')));
      await _waitFor(() => emissions.last.length == 1);
      await repository.deleteObservation(
        ownerId: ownerId,
        observationId: observation.id,
        deletedAt: DateTime.utc(2026, 1, 2),
      );
      await _waitFor(() => emissions.last.isEmpty);
      await repository.restoreObservation(
        ownerId: ownerId,
        observationId: observation.id,
        restoredAt: DateTime.utc(2026, 1, 3),
      );
      await _waitFor(() => emissions.last.length == 1);
      await (database.delete(
        database.observations,
      )..where((t) => t.id.equals(observation.id))).go();
      await _waitFor(() => emissions.last.isEmpty);
    },
  );

  test('rebuild is idempotent and null transitions stay consistent', () async {
    final observation = _observation('one', ownerId, deviceId, null, 1);
    await repository.create(observation);
    await (database.update(database.observations)
          ..where((t) => t.id.equals(observation.id)))
        .write(const ObservationsCompanion(rawText: Value(null)));
    await (database.update(database.observations)
          ..where((t) => t.id.equals(observation.id)))
        .write(const ObservationsCompanion(rawText: Value('蓝雪花')));
    await database.rebuildObservationSearchIndex();
    await database.rebuildObservationSearchIndex();
    final count = await database
        .customSelect(
          "SELECT COUNT(*) AS count FROM observation_search_fts WHERE observation_id = '${observation.id}'",
        )
        .getSingle();
    expect(count.read<int>('count'), 1);
    expect(
      await repository.watchActiveSearch(ownerId: ownerId, query: '蓝雪花').first,
      hasLength(1),
    );
  });
}

Observation _observation(
  String id,
  String owner,
  String device,
  String? text,
  int offset,
) => Observation(
  id: '018f0000-0000-7000-8000-00000000000$offset',
  ownerId: owner,
  inputType: ObservationInputType.text,
  rawText: text,
  capturedAt: DateTime.utc(2026, 1, offset),
  timezoneOffset: 480,
  privacyLevel: PrivacyLevel.normal,
  cloudAiPolicy: CloudAiPolicy.localOnly,
  syncPolicy: SyncPolicy.localOnly,
  createdByDeviceId: device,
  createdAt: DateTime.utc(2026, 1, offset, 1),
  updatedAt: DateTime.utc(2026, 1, offset, 1),
  deletedAt: null,
  serverRevision: null,
);

Future<void> _insertOtherOwner(CognoteDatabase database) async {
  await database
      .into(database.principals)
      .insert(
        PrincipalsCompanion.insert(
          id: 'other-owner',
          kind: 'account',
          status: 'active',
          homeRegion: 'cn-mainland',
          dataResidency: 'cn',
          createdAt: DateTime.utc(2026, 1, 1),
          upgradedAt: const Value(null),
        ),
      );
  await database
      .into(database.deviceIdentities)
      .insert(
        DeviceIdentitiesCompanion.insert(
          id: 'device-other-owner',
          principalId: 'other-owner',
          publicInstallId: 'install-other-owner',
          createdAt: DateTime.utc(2026, 1, 1),
          lastSeenAt: DateTime.utc(2026, 1, 1),
        ),
      );
}

Future<void> _waitFor(bool Function() condition) async {
  for (var i = 0; i < 100; i++) {
    if (condition()) return;
    await Future<void>.delayed(const Duration(milliseconds: 10));
  }
  fail('Timed out waiting for stream emission');
}
