import '../../../../../core/core.dart';
import '../entities/user_profile.dart';
import '../repository/profile_repository.dart';

class GetProfile implements UseCase<UserProfile, NoParams> {
  const GetProfile(this._repository);

  final ProfileRepository _repository;

  @override
  Future<UserProfile> call(NoParams params) => _repository.getProfile();
}
