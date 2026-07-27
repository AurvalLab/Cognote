import 'observation.dart';
import 'observation_detail.dart';
import 'observation_search_result.dart';

abstract interface class ObservationQueryRepository {
  Stream<List<Observation>> watchActiveTimeline({required String ownerId});

  Stream<List<Observation>> watchDeletedTimeline({required String ownerId});

  Future<ObservationDetail?> findActiveDetail({
    required String ownerId,
    required String observationId,
  });

  Stream<List<ObservationSearchResult>> watchActiveSearch({
    required String ownerId,
    required String query,
  });
}
