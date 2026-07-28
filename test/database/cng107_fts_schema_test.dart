import 'package:cognote/src/database/cognote_database.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'new database creates schema v3 FTS table and maintenance triggers',
    () async {
      final database = CognoteDatabase(NativeDatabase.memory());
      try {
        final version = await database
            .customSelect('PRAGMA user_version')
            .getSingle();
        expect(version.read<int>('user_version'), 4);

        final objects = await database
            .customSelect(
              "SELECT type, name, sql FROM sqlite_master "
              "WHERE name = 'observation_search_fts' "
              "OR name LIKE 'observation_search_fts_%' "
              'ORDER BY type, name',
            )
            .get();
        final names = objects.map((row) => row.read<String>('name')).toSet();
        expect(names, contains('observation_search_fts'));
        expect(names, contains('observation_search_fts_insert'));
        expect(names, contains('observation_search_fts_update_raw_text'));
        expect(names, contains('observation_search_fts_delete'));

        final tableSql = objects
            .singleWhere(
              (row) => row.read<String>('name') == 'observation_search_fts',
            )
            .read<String>('sql');
        expect(tableSql, contains('observation_id UNINDEXED'));
        expect(tableSql, contains("tokenize = 'trigram case_sensitive 0'"));
        expect(tableSql, isNot(contains("content='")));
      } finally {
        await database.close();
      }
    },
  );
}
