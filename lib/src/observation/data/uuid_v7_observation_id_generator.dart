import 'package:uuid/uuid.dart';

import '../domain/observation_id_generator.dart';

class UuidV7ObservationIdGenerator implements ObservationIdGenerator {
  const UuidV7ObservationIdGenerator();

  @override
  String generate() => const Uuid().v7();
}
