import '../../../../../core/core.dart';
import '../entities/location_level.dart';
import '../repository/location_repository.dart';

class SelectLocationParams {
  const SelectLocationParams({required this.level, required this.optionId});

  final LocationLevel level;
  final String optionId;
}

class SelectLocation implements UseCase<void, SelectLocationParams> {
  const SelectLocation(this._repository);

  final LocationRepository _repository;

  @override
  Future<void> call(SelectLocationParams params) =>
      _repository.select(params.level.selectionLevel, params.optionId);
}
