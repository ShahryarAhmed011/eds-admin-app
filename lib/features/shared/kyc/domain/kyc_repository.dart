import '../../../../core/core.dart';
import 'kyc_record.dart';

abstract interface class KycRepository {
  /// The account's record; blank when nothing is submitted. Approval
  /// finishes the onboarding "KYC" step.
  Future<KycRecord> getRecord();

  /// First submission (`POST /kyc`) or a resubmission (`PUT /kyc`).
  Future<KycRecord> submit(KycSubmission submission);

  /// The name in the profile, to pre-fill "name on card".
  Future<String> profileName();
}

class GetKycRecord implements UseCase<KycRecord, NoParams> {
  const GetKycRecord(this._repository);

  final KycRepository _repository;

  @override
  Future<KycRecord> call(NoParams params) => _repository.getRecord();
}

class SubmitKyc implements UseCase<KycRecord, KycSubmission> {
  const SubmitKyc(this._repository);

  final KycRepository _repository;

  @override
  Future<KycRecord> call(KycSubmission params) => _repository.submit(params);
}

class GetKycProfileName implements UseCase<String, NoParams> {
  const GetKycProfileName(this._repository);

  final KycRepository _repository;

  @override
  Future<String> call(NoParams params) => _repository.profileName();
}
