import '../../../../../core/core.dart';
import '../entities/kyc_applicant.dart';
import '../repository/admin_kyc_repository.dart';

class GetKycReviewQueue implements UseCase<List<KycApplicant>, NoParams> {
  const GetKycReviewQueue(this._repository);

  final AdminKycRepository _repository;

  @override
  Future<List<KycApplicant>> call(NoParams params) =>
      _repository.getReviewQueue();
}
