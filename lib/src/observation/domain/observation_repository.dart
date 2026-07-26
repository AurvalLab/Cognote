import 'observation.dart';
import 'local_asset.dart';

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
}
