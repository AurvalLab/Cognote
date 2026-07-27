import 'dart:async';

import 'package:cognote/src/observation/domain/observation.dart';
import 'package:cognote/src/observation/domain/observation_search_result.dart';
import 'package:cognote/src/presentation/observation_search_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
    'search page covers initial, loading, results, empty, error and clear',
    (tester) async {
      final controller = StreamController<List<ObservationSearchResult>>();
      addTearDown(controller.close);
      String? opened;
      await tester.pumpWidget(
        MaterialApp(
          home: ObservationSearchPage(
            watchSearch: (_) => controller.stream,
            onOpenObservation: (id) => opened = id,
          ),
        ),
      );

      expect(find.text('请输入关键词'), findsWidgets);
      await tester.enterText(find.byType(TextField), '蓝雪花');
      await tester.testTextInput.receiveAction(TextInputAction.search);
      await tester.pump();
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      controller.add([_result]);
      await tester.pump();
      expect(find.text('命中 蓝雪花'), findsOneWidget);
      expect(find.textContaining('text'), findsOneWidget);
      expect(find.textContaining('2026-07-26'), findsOneWidget);
      await tester.tap(find.text('命中 蓝雪花'));
      expect(opened, _result.observation.id);

      controller.add(const []);
      await tester.pump();
      expect(find.text('没有找到匹配记录'), findsOneWidget);
      expect(find.text('蓝雪花'), findsOneWidget);

      controller.addError(StateError('failed'));
      await tester.pump();
      expect(find.text('搜索失败，请重试'), findsOneWidget);

      await tester.tap(find.byTooltip('清空'));
      await tester.pump();
      expect(find.text('请输入关键词'), findsWidgets);
      expect(find.byType(CircularProgressIndicator), findsNothing);
    },
  );
}

final _result = ObservationSearchResult(
  observation: Observation(
    id: '018f1111-1111-7111-8111-111111111111',
    ownerId: 'owner',
    inputType: ObservationInputType.text,
    rawText: '命中 蓝雪花',
    capturedAt: DateTime.utc(2026, 7, 26, 10),
    timezoneOffset: 480,
    privacyLevel: PrivacyLevel.normal,
    cloudAiPolicy: CloudAiPolicy.localOnly,
    syncPolicy: SyncPolicy.localOnly,
    createdByDeviceId: 'device',
    createdAt: DateTime.utc(2026, 7, 26, 10),
    updatedAt: DateTime.utc(2026, 7, 26, 10),
    deletedAt: null,
    serverRevision: null,
  ),
  snippet: '命中 蓝雪花',
);
