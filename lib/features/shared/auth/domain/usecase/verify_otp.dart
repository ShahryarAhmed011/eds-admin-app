import '../../../../../core/core.dart';
import '../entities/signed_in_user.dart';
import '../repository/auth_repository.dart';

class VerifyOtp implements UseCase<SignedInUser, String> {
  const VerifyOtp(this._repository);

  final AuthRepository _repository;

  @override
  Future<SignedInUser> call(String params) => _repository.verifyOtp(params);
}
