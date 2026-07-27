import 'dart:async';

import 'package:cognote/src/observation/domain/observation.dart';
import 'package:cognote/src/presentation/timeline_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('timeline shows loading, empty, text and image entries', (
    tester,
  ) async {
    late StreamController<List<Observation>> controller;
    controller = StreamController<List<Observation>>();
    addTearDown(controller.close);
    await tester.pumpWidget(
      MaterialApp(
        home: TimelinePage(
          timeline: controller.stream,
          onOpenObservation: (_) {},
          onOpenDeletedObservations: () {},
        ),
      ),
    );
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    controller.add(const []);
    await tester.pump();
    expect(find.text('还没有本地记录'), findsOneWidget);

    controller.add([
      _observation('文字', ObservationInputType.text),
      _observation('图片说明', ObservationInputType.image),
    ]);
    await tester.pump();
    expect(find.text('文字'), findsOneWidget);
    expect(find.text('图片说明'), findsOneWidget);
    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is Text && widget.data?.contains('仅本地 · 未分析') == true,
      ),
      findsNWidgets(2),
    );
    expect(find.byIcon(Icons.image_outlined), findsOneWidget);
  });

  testWidgets('timeline opens selected observation', (tester) async {
    String? opened;
    final observation = _observation('open me', ObservationInputType.text);
    await tester.pumpWidget(
      MaterialApp(
        home: TimelinePage(
          timeline: Stream.value([observation]),
          onOpenObservation: (value) => opened = value,
          onOpenDeletedObservations: () {},
        ),
      ),
    );
    await tester.pump();
    await tester.tap(find.text('open me'));
    expect(opened, observation.id);
  });

  testWidgets('timeline shows query failure', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: TimelinePage(
          timeline: Stream<List<Observation>>.error(StateError('read failed')),
          onOpenObservation: (_) {},
          onOpenDeletedObservations: () {},
        ),
      ),
    );
    await tester.pump();
    expect(find.text('读取时间线失败'), findsOneWidget);
  });
}

Observation _observation(String text, ObservationInputType inputType) =>
    Observation(
      id: '018f1111-1111-7111-8111-111111111111',
      ownerId: 'owner',
      inputType: inputType,
      rawText: text,
      capturedAt: DateTime.utc(2026, 7, 26, 10),
      timezoneOffset: 480,
      privacyLevel: PrivacyLevel.normal,
      cloudAiPolicy: CloudAiPolicy.localOnly,
      syncPolicy: SyncPolicy.localOnly,
      createdByDeviceId: 'device',
      createdAt: DateTime.utc(2026, 7, 26, 11),
      updatedAt: DateTime.utc(2026, 7, 26, 11),
      deletedAt: null,
      serverRevision: null,
    );
