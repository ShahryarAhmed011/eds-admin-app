import '../../../../../core/core.dart';
import '../entities/user_profile.dart';
import '../repository/profile_repository.dart';

class UpdateProfile implements UseCase<UserProfile, UserProfile> {
  const UpdateProfile(this._repository);

  final ProfileRepository _repository;

  @override
  Future<UserProfile> call(UserProfile params) =>
      _repository.updateProfile(params);
}
