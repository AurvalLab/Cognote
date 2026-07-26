import 'observation.dart';

abstract interface class ObservationRepository {
  Future<Observation> create(Observation observation);
}
