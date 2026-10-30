import '../../../../../core/core.dart';
import '../entities/otp_challenge.dart';
import '../repository/auth_repository.dart';

class GetPendingVerification implements UseCase<OtpChallenge, NoParams> {
  const GetPendingVerification(this._repository);

  final AuthRepository _repository;

  @override
  Future<OtpChallenge> call(NoParams params) =>
      _repository.getPendingVerification();
}
