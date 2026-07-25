import 'package:cognote/src/database/cognote_database.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late CognoteDatabase database;

  setUp(() {
    database = CognoteDatabase(NativeDatabase.memory());
  });

  tearDown(() async {
    await database.close();
  });

  test('database only limits active anonymous principals', () async {
    final now = DateTime.utc(2026, 7, 25).millisecondsSinceEpoch;

    await database.customStatement(
      "INSERT INTO principals "
      "(id, kind, status, home_region, data_residency, created_at) "
      "VALUES (?, 'account', 'active', 'cn-mainland', 'cn', ?)",
      ['account-1', now],
    );
    await database.customStatement(
      "INSERT INTO principals "
      "(id, kind, status, home_region, data_residency, created_at) "
      "VALUES (?, 'account', 'active', 'cn-mainland', 'cn', ?)",
      ['account-2', now],
    );

    await database.customStatement(
      "INSERT INTO principals "
      "(id, kind, status, home_region, data_residency, created_at) "
      "VALUES (?, 'anonymous', 'active', 'cn-mainland', 'cn', ?)",
      ['anonymous-1', now],
    );
    expect(
      () => database.customStatement(
        "INSERT INTO principals "
        "(id, kind, status, home_region, data_residency, created_at) "
        "VALUES (?, 'anonymous', 'active', 'cn-mainland', 'cn', ?)",
        ['anonymous-2', now],
      ),
      throwsA(isA<SqliteException>()),
    );
  });
}
