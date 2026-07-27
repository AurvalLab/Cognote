import 'dart:io';

import 'package:cognote/src/observation/domain/local_asset.dart';
import 'package:cognote/src/observation/domain/observation.dart';
import 'package:cognote/src/observation/domain/observation_detail.dart';
import 'package:cognote/src/observation/domain/image_observation_exceptions.dart';
import 'package:cognote/src/presentation/observation_detail_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('text detail shows full original text and metadata', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: ObservationDetailPage(
          detail: Future.value(_detail()),
          resolveLocalFile: (_) => throw StateError('not image'),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('完整的\n原始文字'), findsOneWidget);
    expect(find.text('文字记录'), findsOneWidget);
    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is Text && widget.data?.contains('仅本地 · 未分析') == true,
      ),
      findsOneWidget,
    );
  });

  testWidgets('missing image shows placeholder without crashing', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: ObservationDetailPage(
          detail: Future.value(_detail(inputType: ObservationInputType.image)),
          resolveLocalFile: (_) => File('missing.jpg'),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('本地图片不可用'), findsOneWidget);
    expect(find.text('完整的\n原始文字'), findsOneWidget);
  });

  testWidgets('invalid local image uri shows unavailable placeholder', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: ObservationDetailPage(
          detail: Future.value(_detail(inputType: ObservationInputType.image)),
          resolveLocalFile: (_) {
            throw ImageStorageException(ArgumentError.value('../outside.jpg'));
          },
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('本地图片不可用'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('null detail and query failure show distinct states', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: ObservationDetailPage(
          detail: Future.value(null),
          resolveLocalFile: (_) => File('unused.jpg'),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('记录不存在'), findsOneWidget);

    final failedDetail = Future<ObservationDetail?>.delayed(
      Duration.zero,
      () => throw StateError('failed'),
    );
    await tester.pumpWidget(
      MaterialApp(
        home: ObservationDetailPage(
          detail: failedDetail,
          resolveLocalFile: (_) => File('unused.jpg'),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('读取详情失败'), findsOneWidget);
  });
}

ObservationDetail _detail({
  ObservationInputType inputType = ObservationInputType.text,
}) => ObservationDetail(
  observation: Observation(
    id: '018f1111-1111-7111-8111-111111111111',
    ownerId: 'owner',
    inputType: inputType,
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
  localAsset: inputType == ObservationInputType.image
      ? LocalAsset(
          id: 'asset',
          observationId: '018f1111-1111-7111-8111-111111111111',
          localUri: 'originals/image.jpg',
          analysisDerivativeUri: null,
          localOriginalPresent: true,
          mimeType: 'image/jpeg',
          bytes: 10,
          width: 1,
          height: 1,
          sha256: 'hash',
          exifRemoved: false,
          uploadState: 'local_only',
          createdAt: DateTime.utc(2026, 7, 26, 11),
          updatedAt: DateTime.utc(2026, 7, 26, 11),
        )
      : null,
);
