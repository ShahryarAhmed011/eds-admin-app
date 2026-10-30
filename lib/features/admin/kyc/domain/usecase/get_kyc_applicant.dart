import '../../../../../core/core.dart';
import '../entities/kyc_applicant.dart';
import '../repository/admin_kyc_repository.dart';

class GetKycApplicant implements UseCase<KycApplicant, String> {
  const GetKycApplicant(this._repository);

  final AdminKycRepository _repository;

  @override
  Future<KycApplicant> call(String id) => _repository.getApplicant(id);
}
