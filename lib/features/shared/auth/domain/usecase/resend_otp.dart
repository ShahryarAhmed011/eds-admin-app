import '../../../../../core/core.dart';
import '../entities/otp_challenge.dart';
import '../repository/auth_repository.dart';

class ResendOtp implements UseCase<OtpChallenge, NoParams> {
  const ResendOtp(this._repository);

  final AuthRepository _repository;

  @override
  Future<OtpChallenge> call(NoParams params) => _repository.resendOtp();
}
