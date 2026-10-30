import 'dart:typed_data';

import '../dto/kyc_submission_dto.dart';

abstract interface class AdminKycDataSource {
  /// `GET /admin/kyc` — every KYC awaiting a verdict, oldest first.
  Future<List<KycSubmissionDto>> fetchPending();

  /// `GET /admin/kyc/{userId}/images/{slot}`: one document's bytes, or
  /// null when it wasn't sent.
  Future<Uint8List?> fetchImage(String userId, String slot);

  /// `POST /admin/kyc` `{user_id, is_accepted}`.
  ///
  /// The API has no field for the reviewer's reason; it is collected in the
  /// UI but not sent.
  Future<KycSubmissionDto> submitDecision({
    required String userId,
    required bool isAccepted,
  });
}
