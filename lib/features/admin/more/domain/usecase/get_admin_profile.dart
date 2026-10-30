import '../../../../../core/core.dart';
import '../entities/admin_profile.dart';
import '../repository/admin_more_repository.dart';

class GetAdminProfile implements UseCase<AdminProfile, NoParams> {
  const GetAdminProfile(this._repository);

  final AdminMoreRepository _repository;

  @override
  Future<AdminProfile> call(NoParams params) => _repository.getProfile();
}
