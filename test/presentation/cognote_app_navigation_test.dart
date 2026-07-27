import 'dart:io';

import 'package:cognote/src/application/cognote_application.dart';
import 'package:cognote/src/database/cognote_database.dart';
import 'package:cognote/src/observation/data/file_asset_storage.dart';
import 'package:cognote/src/observation/domain/observation_id_generator.dart';
import 'package:cognote/src/presentation/cognote_app.dart';
import 'package:cognote/src/presentation/observation_detail_page.dart';
import 'package:cognote/src/presentation/timeline_page.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late Directory root;

  setUp(() async {
    root = await Directory.systemTemp.createTemp('cng105_startup_');
  });

  tearDown(() async {
    if (await root.exists()) await root.delete(recursive: true);
  });

  testWidgets('starts on timeline page', (tester) async {
    final application = await _createApplication(root);

    await tester.pumpWidget(
      CognoteApp(application: application, closeApplicationOnDispose: false),
    );
    await tester.pump();

    expect(find.byType(MaterialApp), findsOneWidget);
    expect(find.byType(TimelinePage), findsOneWidget);
    await _pumpUntilFound(tester, find.text('还没有本地记录'));
    final closeFuture = application.close();
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 1));
    await tester.pump(const Duration(milliseconds: 50));
    await closeFuture;
  });

  testWidgets('opens observation detail from timeline', (tester) async {
    final application = await _createApplication(root);
    final command = application.prepareTextObservation(
      rawText: '启动闭环记录',
      timezoneOffset: 480,
    );
    await application.createTextObservation(command);

    await tester.pumpWidget(
      CognoteApp(application: application, closeApplicationOnDispose: false),
    );
    await _pumpUntilFound(tester, find.text('启动闭环记录'));

    await tester.tap(find.text('启动闭环记录'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 350));

    expect(find.byType(ObservationDetailPage), findsOneWidget);
    expect(find.text('文字记录'), findsOneWidget);
    expect(find.text('启动闭环记录'), findsWidgets);
    final closeFuture = application.close();
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 1));
    await tester.pump(const Duration(milliseconds: 50));
    await closeFuture;
  });
}

Future<CognoteApplication> _createApplication(Directory root) =>
    CognoteApplication.bootstrap(
      databaseFactory: () => CognoteDatabase(NativeDatabase.memory()),
      observationIdGenerator: const _FixedIdGenerator(),
      utcNow: () => DateTime.utc(2026, 7, 26, 10),
      assetStorage: FileAssetStorage(
        root: root,
        clock: () => DateTime.utc(2026, 7, 26),
      ),
    );

Future<void> _pumpUntilFound(
  WidgetTester tester,
  Finder finder, {
  int attempts = 40,
}) async {
  for (var attempt = 0; attempt < attempts; attempt++) {
    await tester.pump(const Duration(milliseconds: 50));
    if (finder.evaluate().isNotEmpty) return;
  }
  fail('Widget not found after ${attempts * 50} ms: $finder');
}

class _FixedIdGenerator implements ObservationIdGenerator {
  const _FixedIdGenerator();

  @override
  String generate() => '018f9999-9999-7999-8999-999999999999';
}
