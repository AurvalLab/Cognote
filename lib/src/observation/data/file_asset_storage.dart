import 'dart:io';

import 'package:path/path.dart' as path;

import '../domain/image_observation_exceptions.dart';
import '../domain/image_source.dart';
import '../domain/observation_repository.dart';

typedef Clock = DateTime Function();

class PreparedAssetFile {
  const PreparedAssetFile({required this.uri, required this.bytes});
  final String uri;
  final int bytes;
}

class FileAssetStorage {
  FileAssetStorage({
    required Directory root,
    required Clock clock,
    bool deleteRootOnClose = false,
  }) : this._(root, clock, deleteRootOnClose);

  FileAssetStorage._(this._root, this._clock, this._deleteRootOnClose);

  final Directory _root;
  final Clock _clock;
  final bool _deleteRootOnClose;

  String preparedUri(String assetId, String extension) =>
      'prepared/$assetId.$extension';

  String finalUri(String assetId, String extension) =>
      'originals/${assetId.substring(0, 2)}/$assetId.$extension';

  Future<PreparedAssetFile> copyToPrepared(
    ImageSource source,
    String uri, {
    int maxBytes = 25 * 1024 * 1024,
  }) async {
    final file = _file(uri);
    await file.parent.create(recursive: true);
    IOSink? sink;
    var count = 0;
    try {
      sink = file.openWrite(mode: FileMode.writeOnly);
      await for (final chunk in source.openRead()) {
        count += chunk.length;
        if (count > maxBytes) throw ImageTooLargeException();
        sink.add(chunk);
      }
      await sink.flush();
      await sink.close();
      sink = null;
      await file.setLastModified(_clock());
      if (count == 0) throw ImageSourceNotReadableException();
      return PreparedAssetFile(uri: uri, bytes: count);
    } catch (error) {
      try {
        await sink?.close();
        if (await file.exists()) await file.delete();
      } catch (_) {}
      if (error is ImageTooLargeException ||
          error is ImageSourceNotReadableException) {
        rethrow;
      }
      throw ImageStorageException(error);
    }
  }

  Future<bool> exists(String uri) => _file(uri).exists();
  Future<int> length(String uri) => _file(uri).length();
  Stream<List<int>> openRead(String uri) => _file(uri).openRead();

  File resolveLocalFile(String uri) => _file(uri);

  Future<void> move(String fromUri, String toUri) async {
    final source = _file(fromUri);
    final target = _file(toUri);
    await target.parent.create(recursive: true);
    try {
      await source.rename(target.path);
    } catch (error) {
      throw ImageStorageException(error);
    }
  }

  Future<void> delete(String uri) async {
    final file = _file(uri);
    if (await file.exists()) await file.delete();
  }

  Future<void> close() async {
    if (_deleteRootOnClose && await _root.exists()) {
      await _root.delete(recursive: true);
    }
  }

  Future<void> reconcile(ObservationRepository repository) async {
    final cutoff = _clock().subtract(const Duration(hours: 24));
    for (final directoryName in ['staging', 'prepared']) {
      final directory = Directory(path.join(_root.path, directoryName));
      if (!await directory.exists()) continue;
      await for (final entity in directory.list(recursive: true)) {
        if (entity is File && (await entity.lastModified()).isBefore(cutoff)) {
          await entity.delete();
        }
      }
    }
    final originals = Directory(path.join(_root.path, 'originals'));
    if (await originals.exists()) {
      final entities = await originals.list(recursive: true).toList()
        ..sort((left, right) => left.path.compareTo(right.path));
      for (final entity in entities) {
        if (entity is! File ||
            !(await entity.lastModified()).isBefore(cutoff)) {
          continue;
        }
        final uri = path
            .relative(entity.path, from: _root.path)
            .replaceAll('\\', '/');
        if (!await repository.isLocalUriReferenced(uri)) {
          await entity.delete();
        }
      }
    }
  }

  File _file(String uri) {
    if (path.isAbsolute(uri) || uri.split(RegExp(r'[/\\]')).contains('..')) {
      throw ImageStorageException(ArgumentError.value(uri));
    }
    final resolved = path.normalize(path.join(_root.path, path.fromUri(uri)));
    if (!path.isWithin(_root.path, resolved)) {
      throw ImageStorageException(ArgumentError.value(uri));
    }
    return File(resolved);
  }
}
