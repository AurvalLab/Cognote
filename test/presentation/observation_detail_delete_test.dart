import 'package:cognote/src/observation/domain/observation.dart';
import 'package:cognote/src/observation/domain/observation_mutation_outcome.dart';
import 'package:cognote/src/observation/domain/observation_detail.dart';
import 'package:cognote/src/presentation/observation_detail_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('deletes after confirmation and closes on success', (
    tester,
  ) async {
    var calls = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: ObservationDetailPage(
          detail: Future.value(_detail()),
          resolveLocalFile: (_) => throw StateError('not image'),
          onDelete: () async {
            calls++;
            return ObservationMutationOutcome.changed;
          },
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.widgetWithText(FilledButton, '删除记录'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, '删除记录'));
    await tester.pumpAndSettle();
    expect(find.text('删除这条记录？'), findsOneWidget);
    expect(find.textContaining('本地图片和原始数据不会被立即删除'), findsOneWidget);
    await tester.tap(find.text('取消'));
    expect(calls, 0);
    expect(find.text('完整的\n原始文字'), findsOneWidget);
    await tester.ensureVisible(find.widgetWithText(FilledButton, '删除记录'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, '删除记录'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('删除'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(calls, 1);
    expect(find.text('记录已删除'), findsOneWidget);
  });

  testWidgets('delete failure keeps detail page and allows retry', (
    tester,
  ) async {
    var calls = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: ObservationDetailPage(
          detail: Future.value(_detail()),
          resolveLocalFile: (_) => throw StateError('not image'),
          onDelete: () async {
            calls++;
            throw StateError('failed');
          },
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.widgetWithText(FilledButton, '删除记录'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, '删除记录'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('删除'));
    await tester.pumpAndSettle();
    expect(find.text('删除失败，请重试'), findsOneWidget);
    expect(find.text('完整的\n原始文字'), findsOneWidget);
    expect(calls, 1);
  });

  testWidgets('delete returning notFound closes invalid detail', (
    tester,
  ) async {
    var calls = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: FilledButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => ObservationDetailPage(
                    detail: Future.value(_detail()),
                    resolveLocalFile: (_) => throw StateError('not image'),
                    onDelete: () async {
                      calls++;
                      return ObservationMutationOutcome.notFound;
                    },
                  ),
                ),
              ),
              child: const Text('打开详情'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('打开详情'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.widgetWithText(FilledButton, '删除记录'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, '删除记录'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('删除'));
    await tester.pumpAndSettle();

    expect(calls, 1);
    expect(find.byType(ObservationDetailPage), findsNothing);
    expect(find.text('打开详情'), findsOneWidget);
    expect(find.text('记录不存在或已无法访问'), findsOneWidget);
    expect(find.text('记录已删除'), findsNothing);
  });
}

ObservationDetail _detail() => ObservationDetail(
  observation: Observation(
    id: '018f1111-1111-7111-8111-111111111111',
    ownerId: 'owner',
    inputType: ObservationInputType.text,
    rawText: '完整的\n原始文字',
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
  ),
  localAsset: null,
);
