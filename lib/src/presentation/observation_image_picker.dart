import 'dart:io';

import 'package:flutter/services.dart';

class PickedObservationImage {
  const PickedObservationImage({
    required this.path,
    required this.mimeType,
    required this.displayName,
  });

  final String path;
  final String? mimeType;
  final String displayName;
}

class ObservationImagePickerException implements Exception {
  const ObservationImagePickerException(this.code);

  final String code;
}

abstract interface class ObservationImagePicker {
  Future<PickedObservationImage?> pickImage();

  Future<void> discardImage(PickedObservationImage image);
}

class AndroidObservationImagePicker implements ObservationImagePicker {
  const AndroidObservationImagePicker({
    this.channel = const MethodChannel(_channelName),
  });

  static const _channelName = 'com.cognote.cognote/observation_image_picker';
  final MethodChannel channel;

  @override
  Future<PickedObservationImage?> pickImage() async {
    final Map<Object?, Object?>? result;
    try {
      result = await channel.invokeMapMethod<Object?, Object?>('pickImage');
    } on PlatformException catch (error) {
      throw ObservationImagePickerException(error.code);
    } on MissingPluginException {
      throw const ObservationImagePickerException('unavailable');
    }
    if (result == null) return null;

    final path = result['path'];
    final mimeType = result['mimeType'];
    final displayName = result['displayName'];
    if (path is! String ||
        path.isEmpty ||
        (mimeType != null && mimeType is! String) ||
        displayName is! String ||
        displayName.isEmpty) {
      throw const ObservationImagePickerException('invalid_result');
    }
    return PickedObservationImage(
      path: path,
      mimeType: _normalizedMimeTypeHint(mimeType as String?),
      displayName: displayName,
    );
  }

  @override
  Future<void> discardImage(PickedObservationImage image) async {
    try {
      final file = File(image.path);
      if (await file.exists()) await file.delete();
    } on FileSystemException {
      // The OS cache remains disposable; cleanup must not crash the UI.
    }
  }
}

String? _normalizedMimeTypeHint(String? value) {
  return switch (value?.trim().toLowerCase()) {
    'image/jpeg' || 'image/jpg' => 'image/jpeg',
    'image/png' => 'image/png',
    'image/webp' => 'image/webp',
    _ => null,
  };
}
