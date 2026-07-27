import 'observation.dart';
import 'observation_detail.dart';

abstract interface class ObservationQueryRepository {
  Stream<List<Observation>> watchActiveTimeline({required String ownerId});

  Future<ObservationDetail?> findActiveDetail({
    required String ownerId,
    required String observationId,
  });
}
