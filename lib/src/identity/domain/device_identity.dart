class DeviceIdentity {
  const DeviceIdentity({
    required this.id,
    required this.principalId,
    required this.publicInstallId,
    required this.createdAt,
    required this.lastSeenAt,
  });

  final String id;
  final String principalId;
  final String publicInstallId;
  final DateTime createdAt;
  final DateTime lastSeenAt;
}
