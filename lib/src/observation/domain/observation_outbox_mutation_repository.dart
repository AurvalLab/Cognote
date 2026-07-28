import '../../outbox/domain/outbox_operation.dart';
import 'observation.dart';
import 'observation_mutation_outcome.dart';
import 'observation_repository.dart';

abstract interface class ObservationOutboxMutationRepository {
  Future<Observation> createTextWithOutbox({
    required Observation observation,
    required OutboxOperation operation,
  });

  Future<ImageObservationAggregate> createImageWithOutbox({
    required ImageObservationAggregate aggregate,
    required OutboxOperation operation,
  });

  Future<ObservationMutationOutcome> deleteWithOutbox({
    required String ownerId,
    required String observationId,
    required DateTime deletedAt,
    required OutboxOperation operation,
  });

  Future<ObservationMutationOutcome> restoreWithOutbox({
    required String ownerId,
    required String observationId,
    required DateTime restoredAt,
    required OutboxOperation operation,
  });
}
