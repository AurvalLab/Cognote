import 'package:flutter/material.dart';

import '../observation/domain/observation.dart';
import '../observation/domain/observation_mutation_outcome.dart';

class DeletedObservationsPage extends StatefulWidget {
  const DeletedObservationsPage({
    required this.observations,
    required this.onRestore,
    super.key,
  });

  final Stream<List<Observation>> observations;
  final Future<ObservationMutationOutcome> Function(String observationId)
  onRestore;

  @override
  State<DeletedObservationsPage> createState() =>
      _DeletedObservationsPageState();
}

class _DeletedObservationsPageState extends State<DeletedObservationsPage> {
  final Set<String> _restoring = {};

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('已删除记录')),
    body: StreamBuilder<List<Observation>>(
      stream: widget.observations,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(child: Text('读取已删除记录失败'));
        }
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final observations = snapshot.data!;
        if (observations.isEmpty) {
          return const Center(child: Text('没有已删除记录'));
        }
        return ListView.builder(
          itemCount: observations.length,
          itemBuilder: (context, index) => _DeletedObservationTile(
            observation: observations[index],
            restoring: _restoring.contains(observations[index].id),
            onRestore: () => _restore(observations[index].id),
          ),
        );
      },
    ),
  );

  Future<void> _restore(String observationId) async {
    if (!_restoring.add(observationId)) return;
    setState(() {});
    try {
      final result = await widget.onRestore(observationId);
      if (!mounted) return;
      if (result == ObservationMutationOutcome.notFound) {
        _show('记录不存在或已无法访问');
      } else {
        _show('记录已恢复');
      }
    } catch (_) {
      if (mounted) _show('恢复失败，请重试');
    } finally {
      _restoring.remove(observationId);
      if (mounted) setState(() {});
    }
  }

  void _show(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }
}

class _DeletedObservationTile extends StatelessWidget {
  const _DeletedObservationTile({
    required this.observation,
    required this.restoring,
    required this.onRestore,
  });

  final Observation observation;
  final bool restoring;
  final VoidCallback onRestore;

  @override
  Widget build(BuildContext context) {
    final isImage = observation.inputType == ObservationInputType.image;
    return ListTile(
      leading: Icon(isImage ? Icons.image_outlined : Icons.notes_outlined),
      title: Text(observation.rawText ?? '图片记录'),
      subtitle: Text(
        '记录时间：${_displayTime(observation)}\n'
        '已删除：${observation.deletedAt?.toIso8601String() ?? ''}',
      ),
      isThreeLine: true,
      trailing: TextButton(
        onPressed: restoring ? null : onRestore,
        child: restoring
            ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Text('恢复'),
      ),
    );
  }
}

String _displayTime(Observation observation) => observation.capturedAt
    .toUtc()
    .add(Duration(minutes: observation.timezoneOffset))
    .toIso8601String()
    .replaceFirst('T', ' ');
