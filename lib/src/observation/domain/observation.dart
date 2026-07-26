enum ObservationInputType { image, text }

enum PrivacyLevel { normal }

enum CloudAiPolicy { localOnly, consentRequired, allowed }

enum SyncPolicy { localOnly, syncEnabled }

class Observation {
  const Observation({
    required this.id,
    required this.ownerId,
    required this.inputType,
    required this.rawText,
    required this.capturedAt,
    required this.timezoneOffset,
    required this.privacyLevel,
    required this.cloudAiPolicy,
    required this.syncPolicy,
    required this.createdByDeviceId,
    required this.createdAt,
    required this.updatedAt,
    required this.deletedAt,
    required this.serverRevision,
  });

  final String id;
  final String ownerId;
  final ObservationInputType inputType;
  final String? rawText;
  final DateTime capturedAt;
  final int timezoneOffset;
  final PrivacyLevel privacyLevel;
  final CloudAiPolicy cloudAiPolicy;
  final SyncPolicy syncPolicy;
  final String createdByDeviceId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final int? serverRevision;
}
