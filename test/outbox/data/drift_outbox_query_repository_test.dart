import 'dart:io';

import 'package:cognote/src/database/cognote_database.dart';
import 'package:cognote/src/identity/application/initialize_local_identity.dart';
import 'package:cognote/src/identity/data/drift_identity_repository.dart';
import 'package:cognote/src/outbox/data/drift_outbox_query_repository.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('in-memory queries', () {
    late CognoteDatabase database;
    late DriftOutboxQueryRepository repository;
    late String ownerId;
    late String deviceId;

    setUp(() async {
      database = CognoteDatabase(NativeDatabase.memory());
      final identity = await InitializeLocalIdentity(
        DriftIdentityRepository(database),
      )();
      ownerId = identity.principal.id;
      deviceId = identity.device.id;
      repository = DriftOutboxQueryRepository(database);
    });
    tearDown(() => database.close());

    test(
      'filters owner rows in SQL and orders FIFO by timestamp then operation id',
      () async {
        await _insertIdentity(database, 'other-owner', 'other-device');
        final sameTime = DateTime.utc(2026, 7, 28, 10);
        await _insert(database, 'op-b', ownerId, deviceId, 'first', sameTime);
        await _insert(database, 'op-a', ownerId, deviceId, 'second', sameTime);
        await _insert(
          database,
          'op-other',
          'other-owner',
          'other-device',
          'hidden',
          sameTime.subtract(const Duration(seconds: 1)),
        );

        final pending = await repository.listPending(ownerId: ownerId);

        expect(pending.map((operation) => operation.operationId), [
          'op-a',
          'op-b',
        ]);
        expect(
          pending.every((operation) => operation.ownerId == ownerId),
          isTrue,
        );
        expect(pending.first.createdAt.isUtc, isTrue);
      },
    );
  });

  test(
    'persists across close and reopen without swallowing close errors',
    () async {
      final directory = await Directory.systemTemp.createTemp(
        'cng108_outbox_query_',
      );
      final file = File('${directory.path}/cognote.sqlite');
      final first = CognoteDatabase(NativeDatabase(file));
      try {
        final identity = await InitializeLocalIdentity(
          DriftIdentityRepository(first),
        )();
        await _insert(
          first,
          'op-persisted',
          identity.principal.id,
          identity.device.id,
          'aggregate',
          DateTime.utc(2026, 7, 28),
        );
      } finally {
        await first.close();
      }
      final reopened = CognoteDatabase(NativeDatabase(file));
      try {
        final identity = await InitializeLocalIdentity(
          DriftIdentityRepository(reopened),
        )();
        final pending = await DriftOutboxQueryRepository(
          reopened,
        ).listPending(ownerId: identity.principal.id);
        expect(pending.single.operationId, 'op-persisted');
      } finally {
        await reopened.close();
        await directory.delete(recursive: true);
      }
    },
  );
}

Future<void> _insert(
  CognoteDatabase database,
  String operationId,
  String ownerId,
  String deviceId,
  String aggregateId,
  DateTime createdAt,
) => database
    .into(database.outboxOperations)
    .insert(
      OutboxOperationsCompanion.insert(
        operationId: operationId,
        ownerId: ownerId,
        deviceId: deviceId,
        aggregateType: 'observation',
        aggregateId: aggregateId,
        operationKind: 'observation_upsert',
        createdAt: createdAt,
      ),
    );

Future<void> _insertIdentity(
  CognoteDatabase database,
  String ownerId,
  String deviceId,
) async {
  final now = DateTime.utc(2026, 7, 28).millisecondsSinceEpoch;
  await database.customStatement(
    "INSERT INTO principals (id, kind, status, home_region, data_residency, created_at) VALUES (?, 'account', 'active', 'cn-mainland', 'cn', ?)",
    [ownerId, now],
  );
  await database.customStatement(
    "INSERT INTO device_identities (id, principal_id, public_install_id, created_at, last_seen_at) VALUES (?, ?, ?, ?, ?)",
    [deviceId, ownerId, '$deviceId-install', now, now],
  );
}
