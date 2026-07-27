import 'package:flutter/material.dart';

import '../observation/domain/observation.dart';

class TimelinePage extends StatelessWidget {
  const TimelinePage({
    required this.timeline,
    required this.onOpenObservation,
    super.key,
  });

  final Stream<List<Observation>> timeline;
  final ValueChanged<String> onOpenObservation;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('时间线')),
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
