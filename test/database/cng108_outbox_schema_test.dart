import 'package:cognote/src/database/cognote_database.dart' hide Observation;

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'new v4 database creates the constrained outbox schema and FIFO index',
    () async {
      final database = CognoteDatabase(NativeDatabase.memory());
      addTearDown(database.close);

      final version = await database
          .customSelect('PRAGMA user_version')
          .getSingle();
      expect(version.read<int>('user_version'), 4);

      final columns = await database
          .customSelect('PRAGMA table_info(outbox_operations)')
          .get();
      expect(columns.map((row) => row.read<String>('name')), [
        'operation_id',
        'owner_id',
        'device_id',
        'aggregate_type',
        'aggregate_id',
        'operation_kind',
        'created_at',
      ]);
      expect(
        columns.map((row) => row.read<String>('name')),
        isNot(containsAll(['payload_json', 'status', 'attempt_count'])),
      );

      final sql = await database
          .customSelect(
            "SELECT sql FROM sqlite_master WHERE type = 'table' AND name = 'outbox_operations'",
          )
          .getSingle();
      expect(sql.read<String>('sql'), contains("'observation'"));
      expect(sql.read<String>('sql'), contains("'observation_upsert'"));
      expect(sql.read<String>('sql'), contains("'observation_delete'"));

      final indexes = await database
          .customSelect('PRAGMA index_list(outbox_operations)')
          .get();
      expect(
        indexes.map((row) => row.read<String>('name')),
        contains('outbox_operations_owner_created_operation'),
      );
    },
  );
}
