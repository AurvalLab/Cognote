import 'dart:async';

import 'package:cognote/src/observation/domain/observation.dart';
import 'package:cognote/src/observation/domain/observation_mutation_outcome.dart';
import 'package:cognote/src/presentation/deleted_observations_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('shows loading, empty, error, and deleted summaries', (
    tester,
  ) async {
    final controller = StreamController<List<Observation>>();
    addTearDown(controller.close);
    await tester.pumpWidget(
      MaterialApp(
        home: DeletedObservationsPage(
          observations: controller.stream,
          onRestore: (_) async => ObservationMutationOutcome.changed,
        ),
      ),
    );
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    controller.add(const []);
    await tester.pump();
    expect(find.text('没有已删除记录'), findsOneWidget);

    controller.add([
      _observation(inputType: ObservationInputType.text, rawText: '已删除文字'),
      _observation(inputType: ObservationInputType.image, rawText: null),
    ]);
    await tester.pump();
    expect(find.text('已删除文字'), findsOneWidget);
    expect(find.text('图片记录'), findsOneWidget);
    expect(find.textContaining('记录时间：'), findsNWidgets(2));
    expect(find.textContaining('已删除：'), findsNWidgets(2));
    expect(find.byType(Image), findsNothing);
    expect(find.text('恢复'), findsNWidgets(2));
  });

  testWidgets('restores once, disables row, and reports success', (
    tester,
  ) async {
    final completer = Completer<ObservationMutationOutcome>();
    var calls = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: DeletedObservationsPage(
          observations: Stream.value([_observation()]),
          onRestore: (_) {
            calls++;
            return completer.future;
          },
        ),
      ),
    );
    await tester.pump();

    await tester.tap(find.text('恢复'));
    await tester.tap(find.text('恢复'));
    expect(calls, 1);
    completer.complete(ObservationMutationOutcome.changed);
    await tester.pumpAndSettle();
    expect(find.text('记录已恢复'), findsOneWidget);
  });

  testWidgets('restore failure keeps row enabled for retry', (tester) async {
    var calls = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: DeletedObservationsPage(
          observations: Stream.value([_observation()]),
          onRestore: (_) async {
            calls++;
            throw StateError('failed');
          },
        ),
      ),
    );
    await tester.pump();

    await tester.tap(find.text('恢复'));
    await tester.pumpAndSettle();
    expect(find.text('恢复失败，请重试'), findsOneWidget);
    await tester.tap(find.text('恢复'));
    await tester.pumpAndSettle();
    expect(calls, 2);
  });

  testWidgets('shows query failure', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: DeletedObservationsPage(
          observations: Stream<List<Observation>>.error(StateError('failed')),
          onRestore: (_) async => ObservationMutationOutcome.changed,
        ),
      ),
    );
    await tester.pump();
    expect(find.text('读取已删除记录失败'), findsOneWidget);
  });
}

Observation _observation({
  ObservationInputType inputType = ObservationInputType.text,
  String? rawText = '已删除文字',
}) => Observation(
  id: '018f1111-1111-7111-8111-111111111111',
  ownerId: 'owner',
  inputType: inputType,
  rawText: rawText,
  capturedAt: DateTime.utc(2026, 7, 26, 10),
  timezoneOffset: 480,
  privacyLevel: PrivacyLevel.normal,
  cloudAiPolicy: CloudAiPolicy.localOnly,
  syncPolicy: SyncPolicy.localOnly,
  createdByDeviceId: 'device',
  createdAt: DateTime.utc(2026, 7, 26, 11),
  updatedAt: DateTime.utc(2026, 7, 28, 1),
  deletedAt: DateTime.utc(2026, 7, 28, 1),
  serverRevision: null,
);
