import 'dart:async';
import 'dart:typed_data';

enum ImageSourceOwnership { external, appOwnedTemporary }

abstract interface class ImageSource {
  String? get declaredMimeType;
  ImageSourceOwnership get ownership;
  Stream<List<int>> openRead();
  Future<void> cleanup();
}

class MemoryImageSource implements ImageSource {
  MemoryImageSource(
    Uint8List bytes, {
    String? declaredMimeType,
    ImageSourceOwnership ownership = ImageSourceOwnership.external,
    Future<void> Function()? onCleanup,
  }) : this._(bytes, declaredMimeType, ownership, onCleanup);

  MemoryImageSource._(
    this.bytes,
    this.declaredMimeType,
    this.ownership,
    this._onCleanup,
  );

  final Uint8List bytes;
  @override
  final String? declaredMimeType;
  @override
  final ImageSourceOwnership ownership;
  final Future<void> Function()? _onCleanup;

  @override
  Stream<List<int>> openRead() => Stream<List<int>>.value(bytes);

  @override
  Future<void> cleanup() async => _onCleanup?.call();
}
