import 'dart:io';

import '../domain/image_source.dart';

class FileImageSource implements ImageSource {
  FileImageSource({
    required this.file,
    this.declaredMimeType,
    this.ownership = ImageSourceOwnership.external,
  });

  final File file;

  @override
  final String? declaredMimeType;

  @override
  final ImageSourceOwnership ownership;

  @override
  Stream<List<int>> openRead() => file.openRead();

  @override
  Future<void> cleanup() async {
    if (ownership != ImageSourceOwnership.appOwnedTemporary) return;
    try {
      if (await file.exists()) await file.delete();
    } on FileSystemException {
      // Cache cleanup is best-effort and must not replace the primary result.
    }
  }
}
