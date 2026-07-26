import 'package:drift/drift.dart';

import 'observations.dart';

class LocalAssets extends Table {
  TextColumn get id => text()();
  TextColumn get observationId =>
      text().references(Observations, #id, onDelete: KeyAction.cascade)();
  TextColumn get localUri => text()();
  TextColumn get analysisDerivativeUri => text().nullable()();
  BoolColumn get localOriginalPresent => boolean()();
  TextColumn get mimeType => text()();
  IntColumn get bytes => integer()();
  IntColumn get width => integer().nullable()();
  IntColumn get height => integer().nullable()();
  TextColumn get sha256 => text()();
  BoolColumn get exifRemoved => boolean()();
  TextColumn get uploadState => text()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  List<String> get customConstraints => [
    'CHECK (bytes > 0)',
    'CHECK ((width IS NULL) = (height IS NULL) AND '
        '(width IS NULL OR (width > 0 AND height > 0)))',
    "CHECK (upload_state IN ('local_only', 'upload_queued', 'uploading', "
        "'uploaded', 'failed_retryable', 'failed_terminal', "
        "'blocked_by_policy'))",
  ];

  @override
  Set<Column<Object>> get primaryKey => {id};
}
