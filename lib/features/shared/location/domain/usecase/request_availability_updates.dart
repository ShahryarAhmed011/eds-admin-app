import '../../../../../core/core.dart';
import '../repository/location_repository.dart';

class RequestAvailabilityUpdates implements UseCase<void, String> {
  const RequestAvailabilityUpdates(this._repository);

  final LocationRepository _repository;

  @override
  Future<void> call(String params) =>
      _repository.requestAvailabilityUpdates(params);
}
