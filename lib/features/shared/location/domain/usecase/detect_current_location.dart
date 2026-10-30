import '../../../../../core/core.dart';
import '../entities/location_level.dart';
import '../repository/location_repository.dart';

class DetectCurrentLocation implements UseCase<String?, LocationLevel> {
  const DetectCurrentLocation(this._repository);

  final LocationRepository _repository;

  @override
  Future<String?> call(LocationLevel params) =>
      _repository.detectCurrent(params.selectionLevel);
}
