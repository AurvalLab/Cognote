import '../../identity/domain/identity_repository.dart';
import '../data/observation_search_query.dart';
import '../domain/observation_query_repository.dart';
import '../domain/observation_search_result.dart';

class WatchObservationSearch {
  const WatchObservationSearch({
    required this._repository,
    required this._localIdentity,
  });

  final ObservationQueryRepository _repository;
  final LocalIdentity _localIdentity;

  Stream<List<ObservationSearchResult>> call(String query) {
    final normalized = ObservationSearchQuery.compile(query).normalized;
    return _repository.watchActiveSearch(
      ownerId: _localIdentity.principal.id,
      query: normalized,
    );
  }
}
