import '../../domain/entities/kyc_applicant.dart';
import '../dto/kyc_submission_dto.dart';

extension KycSubmissionDtoMapper on KycSubmissionDto {
  KycApplicant toEntity() => KycApplicant(
    id: id,
    userId: userId,
    name: nameOnCard.trim().isEmpty ? 'Unnamed applicant' : nameOnCard.trim(),
    role: kycRoleFromApi(role),
    status: kycStatusFromApi(status),
    rawStatus: status,
    cnicLast4: _last4(nicNumber),
    submittedAt: createdAt,
    expiryDate: expiryDate,
    phone: phone,
    shopLabel: shopLabel,
  );
}

KycApplicantRole kycRoleFromApi(String raw) => switch (raw.toLowerCase()) {
  'retailer' => KycApplicantRole.retailer,
  'rider' => KycApplicantRole.rider,
  _ => KycApplicantRole.other,
};

KycReviewStatus kycStatusFromApi(String raw) => switch (raw.toLowerCase()) {
  'pending' ||
  'submitted' ||
  'under_review' ||
  'in_review' => KycReviewStatus.pending,
  'approved' || 'accepted' || 'verified' => KycReviewStatus.approved,
  'rejected' || 'declined' => KycReviewStatus.rejected,
  _ => KycReviewStatus.unknown,
};

/// Only the last four digits ever reach the domain layer.
String _last4(String nic) {
  final digits = nic.replaceAll(RegExp(r'[^0-9]'), '');
  return digits.length < 4 ? '—' : digits.substring(digits.length - 4);
}
