import 'local_asset.dart';
import 'observation.dart';

class ObservationDetail {
  const ObservationDetail({
    required this.observation,
    required this.localAsset,
  });

  final Observation observation;
  final LocalAsset? localAsset;
}
