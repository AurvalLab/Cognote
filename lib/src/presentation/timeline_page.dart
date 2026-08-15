import 'package:flutter/material.dart';

import '../observation/domain/observation.dart';

class TimelinePage extends StatelessWidget {
  const TimelinePage({
    required this.timeline,
    required this.onOpenObservation,
    required this.onOpenDeletedObservations,
    required this.onOpenSearch,
    required this.onCreateObservation,
    super.key,
  });

  final Stream<List<Observation>> timeline;
  final ValueChanged<String> onOpenObservation;
  final VoidCallback onOpenDeletedObservations;
  final VoidCallback onOpenSearch;
  final VoidCallback onCreateObservation;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('时间线'),
      actions: [
        IconButton(
          tooltip: '搜索记录',
          onPressed: onOpenSearch,
          icon: const Icon(Icons.search),
        ),
        IconButton(
          tooltip: '已删除记录',
          onPressed: onOpenDeletedObservations,
          icon: const Icon(Icons.delete_outline),
        ),
      ],
    ),
    floatingActionButton: FloatingActionButton.extended(
      key: const Key('create_observation'),
      onPressed: onCreateObservation,
      icon: const Icon(Icons.add),
      label: const Text('记录此刻'),
    ),
    body: StreamBuilder<List<Observation>>(
      stream: timeline,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(child: Text('读取时间线失败'));
        }
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final observations = snapshot.data!;
        if (observations.isEmpty) {
          return const Center(child: Text('还没有本地记录'));
        }
        return ListView.builder(
          itemCount: observations.length,
          itemBuilder: (context, index) {
            final observation = observations[index];
            final isImage = observation.inputType == ObservationInputType.image;
            return ListTile(
              leading: Icon(
                isImage ? Icons.image_outlined : Icons.notes_outlined,
              ),
              title: Text(
                observation.rawText ?? (isImage ? '图片记录' : '文字记录'),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              subtitle: Text('${_displayTime(observation)}\n仅本地 · 未分析'),
              isThreeLine: true,
              onTap: () => onOpenObservation(observation.id),
            );
          },
        );
      },
    ),
  );
}

String _displayTime(Observation observation) {
  final local = observation.capturedAt.toUtc().add(
    Duration(minutes: observation.timezoneOffset),
  );
  return local.toIso8601String().replaceFirst('T', ' ');
}
