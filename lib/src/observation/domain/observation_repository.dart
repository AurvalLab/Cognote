import 'local_asset.dart';
import 'observation.dart';
import 'observation_mutation_outcome.dart';

class ImageObservationAggregate {
  const ImageObservationAggregate({
    required this.observation,
    required this.localAsset,
  });

  final Observation observation;
  final LocalAsset localAsset;
}

abstract interface class ObservationRepository {
  Future<Observation> create(Observation observation);

  Future<ImageObservationAggregate> createImage(
    ImageObservationAggregate aggregate,
  );

  Future<ImageObservationAggregate?> findImageByObservationId(String id);

  Future<bool> isLocalUriReferenced(String localUri);

  Future<ObservationMutationOutcome> deleteObservation({
    required String ownerId,
    required String observationId,
    required DateTime deletedAt,
  });

  Future<ObservationMutationOutcome> restoreObservation({
    required String ownerId,
    required String observationId,
    required DateTime restoredAt,
  });
}
