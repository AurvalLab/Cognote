import 'dart:io';

import 'package:flutter/material.dart';

import '../observation/domain/observation.dart';
import '../observation/domain/observation_detail.dart';
import '../observation/domain/image_observation_exceptions.dart';

class ObservationDetailPage extends StatelessWidget {
  const ObservationDetailPage({
    required this.detail,
    required this.resolveLocalFile,
    super.key,
  });

  final Future<ObservationDetail?> detail;
  final File Function(String localUri) resolveLocalFile;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('记录详情')),
    body: FutureBuilder<ObservationDetail?>(
      future: detail,
      builder: (context, snapshot) {
        if (snapshot.hasError) return const Center(child: Text('读取详情失败'));
        if (!snapshot.hasData) {
          if (snapshot.connectionState == ConnectionState.done) {
            return const Center(child: Text('记录不存在'));
          }
          return const Center(child: CircularProgressIndicator());
        }
        return _DetailBody(
          detail: snapshot.data!,
          resolveLocalFile: resolveLocalFile,
        );
      },
    ),
  );
}

class _DetailBody extends StatelessWidget {
  const _DetailBody({required this.detail, required this.resolveLocalFile});

  final ObservationDetail detail;
  final File Function(String localUri) resolveLocalFile;

  @override
  Widget build(BuildContext context) {
    final observation = detail.observation;
    final isImage = observation.inputType == ObservationInputType.image;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          isImage ? '图片记录' : '文字记录',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 16),
        if (observation.rawText != null) SelectableText(observation.rawText!),
        const SizedBox(height: 16),
        Text('记录时间：${_displayTime(observation)}'),
        Text('创建时间：${observation.createdAt.toIso8601String()}'),
        const Text('状态：仅本地 · 未分析'),
        if (isImage && detail.localAsset != null) ...[
          const SizedBox(height: 16),
          Text('MIME：${detail.localAsset!.mimeType}'),
          Text('尺寸：${detail.localAsset!.width} × ${detail.localAsset!.height}'),
          Text('大小：${detail.localAsset!.bytes} bytes'),
          const SizedBox(height: 16),
          _LocalImage(
            localUri: detail.localAsset!.localUri,
            resolveLocalFile: resolveLocalFile,
          ),
        ],
      ],
    );
  }
}

class _LocalImage extends StatelessWidget {
  const _LocalImage({required this.localUri, required this.resolveLocalFile});

  final String localUri;
  final File Function(String localUri) resolveLocalFile;

  @override
  Widget build(BuildContext context) {
    try {
      final file = resolveLocalFile(localUri);
      if (!file.existsSync()) return const Text('本地图片不可用');
      return Image.file(
        file,
        errorBuilder: (context, error, stackTrace) => const Text('本地图片不可用'),
      );
    } on ImageStorageException {
      return const Text('本地图片不可用');
    } on FileSystemException {
      return const Text('本地图片不可用');
    }
  }
}

String _displayTime(Observation observation) => observation.capturedAt
    .toUtc()
    .add(Duration(minutes: observation.timezoneOffset))
    .toIso8601String()
    .replaceFirst('T', ' ');
