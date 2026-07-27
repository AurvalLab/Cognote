import '../../identity/domain/identity_repository.dart';
import '../domain/observation_detail.dart';
import '../domain/observation_query_repository.dart';

class GetObservationDetail {
  const GetObservationDetail({
    required ObservationQueryRepository repository,
    required LocalIdentity localIdentity,
  }) : this._(repository, localIdentity);

  const GetObservationDetail._(this._repository, this._localIdentity);

  final ObservationQueryRepository _repository;
  final LocalIdentity _localIdentity;

  Future<ObservationDetail?> call(String observationId) =>
      _repository.findActiveDetail(
        ownerId: _localIdentity.principal.id,
        observationId: observationId,
      );
}
