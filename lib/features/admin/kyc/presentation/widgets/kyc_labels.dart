import '../../../../../core/core.dart';
import '../../../common/admin_common.dart';
import '../../domain/entities/kyc_applicant.dart';

extension KycApplicantRoleLabel on KycApplicantRole {
  /// "Retailer" / "Rider".
  String get label => switch (this) {
    KycApplicantRole.retailer => 'Retailer',
    KycApplicantRole.rider => 'Rider',
    KycApplicantRole.other => 'Applicant',
  };
}

extension KycApplicantUi on KycApplicant {
  /// Badge label; unknown API statuses are shown humanised.
  String badgeLabel(DateTime now) => isOverdue(now)
      ? 'Overdue'
      : switch (status) {
          KycReviewStatus.pending => 'Review',
          KycReviewStatus.approved => 'Approved',
          KycReviewStatus.rejected => 'Rejected',
          KycReviewStatus.unknown => AdminFormat.humanize(rawStatus),
        };

  EdsTone badgeTone(DateTime now) => isOverdue(now)
      ? EdsTone.danger
      : switch (status) {
          KycReviewStatus.pending => EdsTone.warning,
          KycReviewStatus.approved => EdsTone.success,
          KycReviewStatus.rejected => EdsTone.danger,
          KycReviewStatus.unknown => EdsTone.neutral,
        };

  /// "26h waiting", or null when the API sent no timestamp.
  String? waitingLabel(DateTime now) => submittedAt == null
      ? null
      : '${AdminFormat.age(submittedAt!, now: now)} waiting';

  /// "Submitted 9:30 am".
  String? submittedLabel(DateTime now) => submittedAt == null
      ? null
      : 'Submitted ${AdminFormat.dateTime(submittedAt!, now: now)}';
}
