import '../../identity/domain/identity_repository.dart';
import '../domain/observation.dart';
import '../domain/observation_query_repository.dart';

class WatchObservationTimeline {
  const WatchObservationTimeline({
    required ObservationQueryRepository repository,
    required LocalIdentity localIdentity,
  }) : this._(repository, localIdentity);

  const WatchObservationTimeline._(this._repository, this._localIdentity);

  final ObservationQueryRepository _repository;
  final LocalIdentity _localIdentity;

  Stream<List<Observation>> call() =>
      _repository.watchActiveTimeline(ownerId: _localIdentity.principal.id);
}
