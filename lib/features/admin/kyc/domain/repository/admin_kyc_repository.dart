import 'dart:typed_data';

import '../entities/kyc_applicant.dart';

abstract interface class AdminKycRepository {
  /// Pending reviews, oldest first.
  Future<List<KycApplicant>> getReviewQueue();

  /// One of the applicant's documents (slot e.g. `nic_front`), or null.
  Future<Uint8List?> getImage(String userId, String slot);

  Future<KycApplicant> getApplicant(String id);

  /// Returns the applicant with its new status.
  Future<KycApplicant> submitDecision({
    required KycApplicant applicant,
    required KycDecision decision,
    required String reason,
  });
}
