import 'dart:io';

import 'package:cognote/src/application/cognote_application.dart';
import 'package:cognote/src/database/cognote_database.dart';
import 'package:cognote/src/identity/domain/device_identity.dart' as domain;
import 'package:cognote/src/identity/domain/identity_repository.dart';
import 'package:cognote/src/identity/domain/principal.dart' as domain;
import 'package:cognote/src/observation/data/file_asset_storage.dart';
import 'package:cognote/src/presentation/cognote_app.dart';
import 'package:cognote/src/presentation/timeline_page.dart';
import 'package:cognote/src/product_identity.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late Directory assetRoot;
  setUp(() async {
    assetRoot = await Directory.systemTemp.createTemp('cng104_widget_');
  });
  tearDown(() async {
    if (await assetRoot.exists()) await assetRoot.delete(recursive: true);
  });
  testWidgets(
    'minimal root widget mounts without initializing identity again',
    (tester) async {
      final database = _TrackingDatabase();
      var initializationCount = 0;
      final application = await CognoteApplication.bootstrap(
        databaseFactory: () => database,
        identityInitializer: (_) async {
          initializationCount++;
          return _identity();
        },
        assetStorage: FileAssetStorage(
          root: assetRoot,
          clock: () => DateTime.utc(2026, 7, 26),
        ),
      );

      await tester.pumpWidget(
        CognoteApp(application: application, closeApplicationOnDispose: false),
      );

      expect(find.byType(MaterialApp), findsOneWidget);
      expect(
        tester.widget<MaterialApp>(find.byType(MaterialApp)).title,
        productDisplayName,
      );
      expect(productEnglishName, 'Mnora');
      expect(productChineseName, '见藏');
      expect(
        productVision,
        'Mnora is a personal memory system that learns how you see the world.',
      );
      expect(productTagline, '把所见，变成可找回的记忆。');
      expect(find.byType(TimelinePage), findsOneWidget);
      expect(initializationCount, 1);

      await tester.pumpWidget(
        CognoteApp(application: application, closeApplicationOnDispose: false),
      );
      expect(initializationCount, 1);

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump(const Duration(milliseconds: 50));
      await application.close();
      expect(database.closeCount, 1);
    },
  );
}

class _TrackingDatabase extends CognoteDatabase {
  _TrackingDatabase() : super(NativeDatabase.memory());

  int closeCount = 0;

  @override
  Future<void> close() async {
    closeCount++;
    await super.close();
  }
}

LocalIdentity _identity() {
  final createdAt = DateTime.utc(2026, 7, 25);
  const principalId = 'principal';
  return LocalIdentity(
    principal: domain.Principal(
      id: principalId,
      kind: domain.PrincipalKind.anonymous,
      status: domain.PrincipalStatus.active,
      homeRegion: 'cn-mainland',
      dataResidency: 'cn',
      createdAt: createdAt,
      upgradedAt: null,
    ),
    device: domain.DeviceIdentity(
      id: 'device',
      principalId: principalId,
      publicInstallId: 'install',
      createdAt: createdAt,
      lastSeenAt: createdAt,
    ),
  );
}
