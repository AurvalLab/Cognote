class LocalAsset {
  const LocalAsset({
    required this.id,
    required this.observationId,
    required this.localUri,
    required this.analysisDerivativeUri,
    required this.localOriginalPresent,
    required this.mimeType,
    required this.bytes,
    required this.width,
    required this.height,
    required this.sha256,
    required this.exifRemoved,
    required this.uploadState,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String observationId;
  final String localUri;
  final String? analysisDerivativeUri;
  final bool localOriginalPresent;
  final String mimeType;
  final int bytes;
  final int? width;
  final int? height;
  final String sha256;
  final bool exifRemoved;
  final String uploadState;
  final DateTime createdAt;
  final DateTime updatedAt;
}
