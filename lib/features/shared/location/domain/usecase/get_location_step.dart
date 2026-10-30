import '../../../../../core/core.dart';
import '../entities/location_level.dart';
import '../entities/location_step.dart';
import '../repository/location_repository.dart';

class GetLocationStep implements UseCase<LocationStep, LocationLevel> {
  const GetLocationStep(this._repository);

  final LocationRepository _repository;

  @override
  Future<LocationStep> call(LocationLevel params) =>
      _repository.getStep(params);
}
