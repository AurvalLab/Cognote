import 'dart:io';

import 'package:flutter/material.dart';

import '../observation/domain/image_observation_exceptions.dart';
import '../observation/domain/observation.dart';
import '../observation/domain/observation_detail.dart';
import '../observation/domain/observation_mutation_outcome.dart';

class ObservationDetailPage extends StatelessWidget {
  const ObservationDetailPage({
    required this.detail,
    required this.resolveLocalFile,
    this.onDelete,
    super.key,
  });

  final Future<ObservationDetail?> detail;
  final File Function(String localUri) resolveLocalFile;
  final Future<ObservationMutationOutcome> Function()? onDelete;

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
          onDelete: onDelete,
        );
      },
    ),
  );
}

class _DetailBody extends StatefulWidget {
  const _DetailBody({
    required this.detail,
    required this.resolveLocalFile,
    this.onDelete,
  });

  final ObservationDetail detail;
  final File Function(String localUri) resolveLocalFile;
  final Future<ObservationMutationOutcome> Function()? onDelete;

  @override
  State<_DetailBody> createState() => _DetailBodyState();
}

class _DetailBodyState extends State<_DetailBody> {
  bool _deleting = false;

  @override
  Widget build(BuildContext context) {
    final observation = widget.detail.observation;
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
        if (widget.onDelete != null) ...[
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: _deleting ? null : _confirmDelete,
            icon: const Icon(Icons.delete_outline),
            label: Text(_deleting ? '删除中…' : '删除记录'),
          ),
        ],
        if (isImage && widget.detail.localAsset != null) ...[
          const SizedBox(height: 16),
          Text('MIME：${widget.detail.localAsset!.mimeType}'),
          Text(
            '尺寸：${widget.detail.localAsset!.width} × ${widget.detail.localAsset!.height}',
          ),
          Text('大小：${widget.detail.localAsset!.bytes} bytes'),
          const SizedBox(height: 16),
          _LocalImage(
            localUri: widget.detail.localAsset!.localUri,
            resolveLocalFile: widget.resolveLocalFile,
          ),
        ],
      ],
    );
  }

  Future<void> _confirmDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('删除这条记录？'),
        content: const Text('记录将移入“已删除记录”，之后可以恢复。本地图片和原始数据不会被立即删除。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('删除'),
          ),
        ],
      ),
    );
    if (confirmed != true || _deleting || !mounted) return;
    setState(() => _deleting = true);
    try {
      final result = await widget.onDelete!();
      if (!mounted) return;
      if (result == ObservationMutationOutcome.notFound) {
        final messenger = ScaffoldMessenger.of(context);
        Navigator.of(context).pop();
        messenger.showSnackBar(const SnackBar(content: Text('记录不存在或已无法访问')));
        return;
      } else {
        final messenger = ScaffoldMessenger.of(context);
        Navigator.of(context).pop();
        messenger.showSnackBar(const SnackBar(content: Text('记录已删除')));
      }
    } catch (_) {
      if (mounted) _show('删除失败，请重试');
    } finally {
      if (mounted) setState(() => _deleting = false);
    }
  }

  void _show(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
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
