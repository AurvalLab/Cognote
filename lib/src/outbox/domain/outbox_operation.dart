class OutboxOperation {
  const OutboxOperation({
    required this.operationId,
    required this.ownerId,
    required this.deviceId,
    required this.aggregateType,
    required this.aggregateId,
    required this.operationKind,
    required this.createdAt,
  });

  final String operationId;
  final String ownerId;
  final String deviceId;
  final String aggregateType;
  final String aggregateId;
  final String operationKind;
  final DateTime createdAt;
}
