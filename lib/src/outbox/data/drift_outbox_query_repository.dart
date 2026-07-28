import 'package:drift/drift.dart';

import '../../database/cognote_database.dart' as drift;
import '../domain/outbox_operation.dart';
import '../domain/outbox_query_repository.dart';

class DriftOutboxQueryRepository implements OutboxQueryRepository {
  const DriftOutboxQueryRepository(this._database);

  final drift.CognoteDatabase _database;

  @override
  Future<List<OutboxOperation>> listPending({required String ownerId}) {
    final query = _database.select(_database.outboxOperations)
      ..where((table) => table.ownerId.equals(ownerId))
      ..orderBy([
        (table) => OrderingTerm.asc(table.createdAt),
        (table) => OrderingTerm.asc(table.operationId),
      ]);
    return query.get().then(
      (rows) => rows
          .map(
            (row) => OutboxOperation(
              operationId: row.operationId,
              ownerId: row.ownerId,
              deviceId: row.deviceId,
              aggregateType: row.aggregateType,
              aggregateId: row.aggregateId,
              operationKind: row.operationKind,
              createdAt: row.createdAt.toUtc(),
            ),
          )
          .toList(growable: false),
    );
  }
}
