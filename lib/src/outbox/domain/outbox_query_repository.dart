import 'outbox_operation.dart';

abstract interface class OutboxQueryRepository {
  Future<List<OutboxOperation>> listPending({required String ownerId});
}
