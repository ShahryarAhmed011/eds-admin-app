import '../../../../../core/core.dart';
import '../entities/service_area.dart';
import '../repository/admin_areas_repository.dart';

class GetServiceableAreas implements UseCase<ServiceAreaScope, NoParams> {
  const GetServiceableAreas(this._repository);

  final AdminAreasRepository _repository;

  @override
  Future<ServiceAreaScope> call(NoParams params) => _repository.getScope();
}
