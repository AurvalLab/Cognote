import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:image/image.dart' as img;
import 'package:uuid/uuid.dart';

import '../../identity/domain/identity_repository.dart';
import '../data/file_asset_storage.dart';
import '../domain/image_observation_exceptions.dart';
import '../domain/image_source.dart';
import '../domain/local_asset.dart';
import '../domain/observation.dart';
import '../domain/observation_exceptions.dart';
import '../domain/observation_id_generator.dart';
import '../domain/observation_repository.dart';

export '../domain/image_observation_exceptions.dart';
export '../domain/observation_exceptions.dart';

class PreparedImageObservationCommand {
  const PreparedImageObservationCommand({
    required this.observationId,
    required this.localAssetId,
    required this.caption,
    required this.capturedAtUtc,
    required this.timezoneOffset,
    required this.preparedUri,
    required this.finalUri,
    required this.mimeType,
    required this.bytes,
    required this.width,
    required this.height,
    required this.sha256,
  });

  final String observationId;
  final String localAssetId;
  final String? caption;
  final DateTime capturedAtUtc;
  final int timezoneOffset;
  final String preparedUri;
  final String finalUri;
  final String mimeType;
  final int bytes;
  final int width;
  final int height;
  final String sha256;
}

class CreateImageObservation {
  const CreateImageObservation({
    required ObservationRepository repository,
    required LocalIdentity localIdentity,
    required ObservationIdGenerator observationIdGenerator,
    required ObservationIdGenerator localAssetIdGenerator,
    required FileAssetStorage assetStorage,
    required Clock clock,
  }) : this._(
         repository,
         localIdentity,
         observationIdGenerator,
         localAssetIdGenerator,
         assetStorage,
         clock,
       );

  const CreateImageObservation._(
    this._repository,
    this._localIdentity,
    this._observationIdGenerator,
    this._localAssetIdGenerator,
    this._assetStorage,
    this._clock,
  );

  final ObservationRepository _repository;
  final LocalIdentity _localIdentity;
  final ObservationIdGenerator _observationIdGenerator;
  final ObservationIdGenerator _localAssetIdGenerator;
  final FileAssetStorage _assetStorage;
  final Clock _clock;

  Future<PreparedImageObservationCommand> prepare({
    required ImageSource source,
    String? caption,
    DateTime? capturedAtUtc,
    required int timezoneOffset,
  }) async {
    if (timezoneOffset < -840 || timezoneOffset > 840) {
      throw InvalidTimezoneOffsetException();
    }
    final capturedAt = capturedAtUtc ?? _clock();
    if (!capturedAt.isUtc) {
      throw InvalidCapturedAtException();
    }
    final observationId = _validatedId(_observationIdGenerator.generate());
    final assetId = _validatedId(_localAssetIdGenerator.generate());
    try {
      await _assetStorage.reconcile(_repository);
    } catch (error) {
      throw ImageStorageException(error);
    }
    final stagingUri = 'staging/$assetId.part';
    PreparedAssetFile staged;
    try {
      staged = await _assetStorage.copyToPrepared(source, stagingUri);
    } catch (_) {
      rethrow;
    }
    try {
      final bytes = Uint8List.fromList(
        await _assetStorage
            .openRead(stagingUri)
            .expand((item) => item)
            .toList(),
      );
      final detected = _detect(bytes);
      if (source.declaredMimeType != null &&
          source.declaredMimeType!.toLowerCase() != detected.mimeType) {
        throw UnsupportedImageException();
      }
      validateImageDimensions(width: detected.width, height: detected.height);
      final preparedUri = _assetStorage.preparedUri(
        assetId,
        detected.extension,
      );
      final finalUri = _assetStorage.finalUri(assetId, detected.extension);
      await _assetStorage.move(stagingUri, preparedUri);
      if (source.ownership == ImageSourceOwnership.appOwnedTemporary) {
        await source.cleanup();
      }
      return PreparedImageObservationCommand(
        observationId: observationId,
        localAssetId: assetId,
        caption: caption == null || caption.trim().isEmpty ? null : caption,
        capturedAtUtc: capturedAt,
        timezoneOffset: timezoneOffset,
        preparedUri: preparedUri,
        finalUri: finalUri,
        mimeType: detected.mimeType,
        bytes: staged.bytes,
        width: detected.width,
        height: detected.height,
        sha256: sha256.convert(bytes).toString(),
      );
    } catch (_) {
      await _assetStorage.delete(stagingUri);
      rethrow;
    }
  }

  Future<ImageObservationAggregate> execute(
    PreparedImageObservationCommand command,
  ) async {
    var movedPreparedToFinal = false;
    final existing = await _repository.findImageByObservationId(
      command.observationId,
    );
    if (existing != null) {
      if (!await _assetStorage.exists(command.finalUri) ||
          await _hash(command.finalUri) != command.sha256) {
        throw AssetIntegrityException();
      }
    } else if (!await _assetStorage.exists(command.finalUri)) {
      if (!await _assetStorage.exists(command.preparedUri)) {
        throw AssetIntegrityException();
      }
      await _assetStorage.move(command.preparedUri, command.finalUri);
      movedPreparedToFinal = true;
    } else if (await _hash(command.finalUri) != command.sha256) {
      throw AssetDestinationConflictException();
    }
    final now = _clock();
    final aggregate = ImageObservationAggregate(
      observation: Observation(
        id: command.observationId,
        ownerId: _localIdentity.principal.id,
        inputType: ObservationInputType.image,
        rawText: command.caption,
        capturedAt: command.capturedAtUtc,
        timezoneOffset: command.timezoneOffset,
        privacyLevel: PrivacyLevel.normal,
        cloudAiPolicy: CloudAiPolicy.localOnly,
        syncPolicy: SyncPolicy.localOnly,
        createdByDeviceId: _localIdentity.device.id,
        createdAt: now,
        updatedAt: now,
        deletedAt: null,
        serverRevision: null,
      ),
      localAsset: LocalAsset(
        id: command.localAssetId,
        observationId: command.observationId,
        localUri: command.finalUri,
        analysisDerivativeUri: null,
        localOriginalPresent: true,
        mimeType: command.mimeType,
        bytes: command.bytes,
        width: command.width,
        height: command.height,
        sha256: command.sha256,
        exifRemoved: false,
        uploadState: 'local_only',
        createdAt: now,
        updatedAt: now,
      ),
    );
    try {
      return await _repository.createImage(aggregate);
    } catch (persistenceError) {
      if (!movedPreparedToFinal) {
        rethrow;
      }
      try {
        await _assetStorage.move(command.finalUri, command.preparedUri);
      } catch (compensationError) {
        throw ImagePersistenceCompensationException(
          persistenceError,
          compensationError,
        );
      }
      rethrow;
    }
  }

  Future<String> _hash(String uri) async => sha256
      .bind(_assetStorage.openRead(uri))
      .first
      .then((value) => value.toString());
}

String _validatedId(String value) {
  if (!Uuid.isValidUUID(fromString: value) ||
      !value.split('-')[2].startsWith('7')) {
    throw InvalidObservationIdException();
  }
  return value;
}

void validateImageDimensions({required int width, required int height}) {
  if (width <= 0 ||
      height <= 0 ||
      width > 16384 ||
      height > 16384 ||
      width * height > 50000000) {
    throw InvalidImageDimensionsException();
  }
}

_ImageInfo _detect(Uint8List bytes) {
  if (bytes.length >= 6 &&
      String.fromCharCodes(bytes.take(6)).startsWith('GIF')) {
    throw UnsupportedImageException();
  }
  final isWebp =
      bytes.length >= 16 &&
      String.fromCharCodes(bytes.sublist(0, 4)) == 'RIFF' &&
      String.fromCharCodes(bytes.sublist(8, 12)) == 'WEBP';
  if (isWebp && String.fromCharCodes(bytes).contains('ANIM')) {
    throw UnsupportedImageException();
  }
  img.Decoder? decoder;
  img.Image? image;
  try {
    decoder = img.findDecoderForData(bytes);
    image = decoder?.decode(bytes);
  } catch (_) {
    throw UnsupportedImageException();
  }
  if (decoder == null || image == null || image.numFrames != 1) {
    throw UnsupportedImageException();
  }
  if (bytes.length >= 3 && bytes[0] == 0xff && bytes[1] == 0xd8) {
    return _ImageInfo('image/jpeg', 'jpg', image.width, image.height);
  }
  if (bytes.length >= 8 && bytes[0] == 0x89 && bytes[1] == 0x50) {
    return _ImageInfo('image/png', 'png', image.width, image.height);
  }
  if (isWebp) {
    return _ImageInfo('image/webp', 'webp', image.width, image.height);
  }
  throw UnsupportedImageException();
}

class _ImageInfo {
  const _ImageInfo(this.mimeType, this.extension, this.width, this.height);
  final String mimeType;
  final String extension;
  final int width;
  final int height;
}
