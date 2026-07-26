class ImageSourceNotReadableException implements Exception {}

class UnsupportedImageException implements Exception {}

class ImageTooLargeException implements Exception {}

class InvalidImageDimensionsException implements Exception {}

class ImageStorageException implements Exception {
  ImageStorageException([this.cause]);
  final Object? cause;
}

class AssetDestinationConflictException implements Exception {}

class AssetIntegrityException implements Exception {}

class LocalAssetIdConflictException implements Exception {}

class ImagePersistenceCompensationException implements Exception {
  ImagePersistenceCompensationException(
    this.persistenceError,
    this.compensationError,
  );
  final Object persistenceError;
  final Object compensationError;
}
