import 'package:equatable/equatable.dart';

import '../../../../../core/core.dart';
import '../entities/kyc_applicant.dart';
import '../repository/admin_kyc_repository.dart';

class SubmitKycDecision implements UseCase<KycApplicant, KycDecisionParams> {
  const SubmitKycDecision(this._repository);

  final AdminKycRepository _repository;

  @override
  Future<KycApplicant> call(KycDecisionParams params) =>
      _repository.submitDecision(
        applicant: params.applicant,
        decision: params.decision,
        reason: params.reason,
      );
}

class KycDecisionParams extends Equatable {
  const KycDecisionParams({
    required this.applicant,
    required this.decision,
    required this.reason,
  });

  final KycApplicant applicant;
  final KycDecision decision;
  final String reason;

  @override
  List<Object?> get props => [applicant, decision, reason];
}
