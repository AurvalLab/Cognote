import 'observation.dart';

class ObservationSearchResult {
  const ObservationSearchResult({
    required this.observation,
    required this.snippet,
  });

  final Observation observation;
  final String snippet;
}
