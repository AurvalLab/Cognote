import 'dart:io';

import 'package:cognote/src/database/cognote_database.dart';
import 'package:cognote/src/identity/application/initialize_local_identity.dart';
import 'package:cognote/src/identity/data/drift_identity_repository.dart';
import 'package:drift/drift.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('two database connections converge on one identity', () async {
    driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
    final directory = await Directory.systemTemp.createTemp(
      'cognote_identity_concurrent_',
    );
    final firstDatabase = CognoteDatabase.open(directory: directory);
    final secondDatabase = CognoteDatabase.open(directory: directory);

    try {
      await firstDatabase.customSelect('SELECT 1').getSingle();
      await secondDatabase.customSelect('SELECT 1').getSingle();

      final identities = await Future.wait([
        InitializeLocalIdentity(DriftIdentityRepository(firstDatabase))(),
        InitializeLocalIdentity(DriftIdentityRepository(secondDatabase))(),
      ]);

      expect(identities.map((item) => item.principal.id).toSet(), hasLength(1));
      expect(identities.map((item) => item.device.id).toSet(), hasLength(1));
      expect(
        identities.map((item) => item.device.publicInstallId).toSet(),
        hasLength(1),
      );
    } finally {
      await firstDatabase.close();
      await secondDatabase.close();
      driftRuntimeOptions.dontWarnAboutMultipleDatabases = false;
      await _deleteDirectoryWhenReleased(directory);
    }
  });

  test('identity survives closing and reopening the SQLite database', () async {
    final directory = await Directory.systemTemp.createTemp(
      'cognote_identity_',
    );

    try {
      final firstDatabase = CognoteDatabase.open(directory: directory);
      final firstIdentity = await InitializeLocalIdentity(
        DriftIdentityRepository(firstDatabase),
      )();
      await firstDatabase.close();

      final reopenedDatabase = CognoteDatabase.open(directory: directory);
      try {
        final reopenedIdentity = await InitializeLocalIdentity(
          DriftIdentityRepository(reopenedDatabase),
        )();

        expect(reopenedIdentity.principal.id, firstIdentity.principal.id);
        expect(reopenedIdentity.device.id, firstIdentity.device.id);
        expect(
          reopenedIdentity.device.publicInstallId,
          firstIdentity.device.publicInstallId,
        );
        expect(reopenedIdentity.principal.createdAt.isUtc, isTrue);
        expect(reopenedIdentity.device.createdAt.isUtc, isTrue);
        expect(reopenedIdentity.device.lastSeenAt.isUtc, isTrue);
      } finally {
        await reopenedDatabase.close();
      }
    } finally {
      await _deleteDirectoryWhenReleased(directory);
    }
  });
}

Future<void> _deleteDirectoryWhenReleased(Directory directory) async {
  for (var attempt = 0; attempt < 10; attempt++) {
    try {
      await directory.delete(recursive: true);
      return;
    } on PathAccessException {
      if (attempt == 9) {
        rethrow;
      }
      await Future<void>.delayed(const Duration(milliseconds: 50));
    }
  }
}
