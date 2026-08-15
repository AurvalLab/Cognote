import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';

import '../observation/domain/image_observation_exceptions.dart';
import '../observation/domain/observation_exceptions.dart';
import 'observation_image_picker.dart';

typedef CreateTextRecord =
    Future<String> Function({
      required String rawText,
      required int timezoneOffset,
    });
typedef CreateImageRecord =
    Future<String> Function({
      required PickedObservationImage image,
      required String? caption,
      required int timezoneOffset,
      required VoidCallback onPrepared,
    });

enum _CreationMode { text, image }

class CreateObservationPage extends StatefulWidget {
  const CreateObservationPage({
    required this.imagePicker,
    required this.onCreateText,
    required this.onCreateImage,
    super.key,
  });

  final ObservationImagePicker imagePicker;
  final CreateTextRecord onCreateText;
  final CreateImageRecord onCreateImage;

  @override
  State<CreateObservationPage> createState() => _CreateObservationPageState();
}

class _CreateObservationPageState extends State<CreateObservationPage> {
  final _textController = TextEditingController();
  final _captionController = TextEditingController();
  _CreationMode _mode = _CreationMode.text;
  PickedObservationImage? _pickedImage;
  bool _busy = false;
  String? _status;
  bool _statusIsError = false;

  @override
  void dispose() {
    final pickedImage = _pickedImage;
    if (pickedImage != null) {
      unawaited(_discardImage(pickedImage));
    }
    _textController.dispose();
    _captionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => PopScope(
    canPop: !_busy,
    child: Scaffold(
      appBar: AppBar(title: const Text('记录此刻')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            SegmentedButton<_CreationMode>(
              segments: const [
                ButtonSegment(
                  value: _CreationMode.text,
                  label: Text('文字'),
                  icon: Icon(Icons.notes_outlined),
                ),
                ButtonSegment(
                  value: _CreationMode.image,
                  label: Text('图片'),
                  icon: Icon(Icons.image_outlined),
                ),
              ],
              selected: {_mode},
              onSelectionChanged: _busy
                  ? null
                  : (selection) {
                      setState(() {
                        _mode = selection.single;
                        _status = null;
                        _statusIsError = false;
                      });
                    },
            ),
            const SizedBox(height: 20),
            if (_mode == _CreationMode.text)
              TextField(
                key: const Key('create_text_input'),
                controller: _textController,
                enabled: !_busy,
                minLines: 6,
                maxLines: 12,
                autofocus: true,
                decoration: const InputDecoration(
                  labelText: '写下你此刻看到或想到的事',
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(),
                ),
              )
            else ...[
              OutlinedButton.icon(
                key: const Key('pick_observation_image'),
                onPressed: _busy ? null : _pickImage,
                icon: const Icon(Icons.add_photo_alternate_outlined),
                label: Text(_pickedImage == null ? '选择一张图片' : '重新选择图片'),
              ),
              if (_pickedImage != null) ...[
                const SizedBox(height: 8),
                Text(
                  _pickedImage!.displayName,
                  key: const Key('picked_image_name'),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              const SizedBox(height: 16),
              TextField(
                key: const Key('create_image_caption'),
                controller: _captionController,
                enabled: !_busy,
                minLines: 2,
                maxLines: 5,
                decoration: const InputDecoration(
                  labelText: '可选说明',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
            if (_status != null) ...[
              const SizedBox(height: 16),
              Text(
                _status!,
                key: const Key('create_observation_status'),
                style: TextStyle(
                  color: _statusIsError
                      ? Theme.of(context).colorScheme.error
                      : Theme.of(context).colorScheme.primary,
                ),
              ),
            ],
            const SizedBox(height: 24),
            FilledButton.icon(
              key: const Key('save_observation'),
              onPressed: _busy ? null : _submit,
              icon: _busy
                  ? const SizedBox.square(
                      dimension: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.save_outlined),
              label: Text(_busy ? '处理中' : '保存到本地'),
            ),
            const SizedBox(height: 8),
            const Text('仅保存到这台设备，不需要网络。', textAlign: TextAlign.center),
          ],
        ),
      ),
    ),
  );

  Future<void> _pickImage() async {
    if (_busy) return;
    setState(() {
      _busy = true;
      _status = '正在打开系统图片选择器';
      _statusIsError = false;
    });
    try {
      final image = await widget.imagePicker.pickImage();
      if (!mounted) {
        if (image != null) await _discardImage(image);
        return;
      }
      final previousImage = _pickedImage;
      if (image != null && previousImage != null) {
        // Release page ownership before asynchronous cleanup so dispose cannot
        // schedule a second deletion for the same temporary file.
        _pickedImage = null;
        await _discardImage(previousImage);
        if (!mounted) {
          await _discardImage(image);
          return;
        }
      }
      setState(() {
        _pickedImage = image ?? _pickedImage;
        _busy = false;
        _status = image == null ? null : '已选择图片';
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _busy = false;
        _statusIsError = true;
        _status = _messageFor(error, picking: true);
      });
    }
  }

  Future<void> _submit() async {
    if (_busy) return;
    final image = _pickedImage;
    if (_mode == _CreationMode.text && _textController.text.trim().isEmpty) {
      setState(() {
        _status = '请先写下一些内容';
        _statusIsError = true;
      });
      return;
    }
    if (_mode == _CreationMode.image && image == null) {
      setState(() {
        _status = '请先选择一张图片';
        _statusIsError = true;
      });
      return;
    }

    setState(() {
      _busy = true;
      _statusIsError = false;
      _status = _mode == _CreationMode.text ? '正在保存文字' : '正在准备图片';
      if (_mode == _CreationMode.image) {
        // The Application owns and cleans the temporary file once invoked.
        _pickedImage = null;
      }
    });
    try {
      final timezoneOffset = DateTime.now().timeZoneOffset.inMinutes;
      final observationId = _mode == _CreationMode.text
          ? await widget.onCreateText(
              rawText: _textController.text,
              timezoneOffset: timezoneOffset,
            )
          : await widget.onCreateImage(
              image: image!,
              caption: _captionController.text,
              timezoneOffset: timezoneOffset,
              onPrepared: () {
                if (!mounted) return;
                setState(() => _status = '正在保存图片');
              },
            );
      if (!mounted) return;
      setState(() => _busy = false);
      Navigator.of(context).pop(observationId);
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _busy = false;
        _statusIsError = true;
        _status = _messageFor(error);
      });
    }
  }

  Future<void> _discardImage(PickedObservationImage image) async {
    try {
      await widget.imagePicker.discardImage(image);
    } catch (_) {
      // Cache cleanup is best-effort and must not replace the primary result.
    }
  }
}

String _messageFor(Object error, {bool picking = false}) {
  if (error is InvalidObservationTextException) {
    return '请先写下一些内容';
  }
  if (error is ImageTooLargeException ||
      error is ObservationImagePickerException && error.code == 'too_large') {
    return '图片不能超过 25 MiB';
  }
  if (error is UnsupportedImageException ||
      error is InvalidImageDimensionsException) {
    return '请选择有效的 JPEG、PNG 或静态 WebP 图片';
  }
  if (error is ObservationImagePickerException) {
    return switch (error.code) {
      'unavailable' => '系统图片选择器不可用，请稍后重试',
      'busy' => '图片选择器正在使用，请稍后重试',
      'unsupported' => '请选择有效的 JPEG、PNG 或静态 WebP 图片',
      'storage' => '本地存储失败，请检查设备空间后重试',
      'unreadable' || 'invalid_result' => '无法读取所选图片，请重新选择',
      _ => picking ? '无法打开图片选择器，请重试' : '保存失败，请重试',
    };
  }
  if (error is ImageSourceNotReadableException) {
    return '无法读取所选图片，请重新选择';
  }
  if (error is ImageStorageException ||
      error is FileSystemException ||
      error is AssetDestinationConflictException ||
      error is AssetIntegrityException ||
      error is ImagePersistenceCompensationException) {
    return '本地存储失败，请检查设备空间后重试';
  }
  return picking ? '无法打开图片选择器，请重试' : '保存失败，请重试';
}
