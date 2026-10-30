import 'dart:typed_data';

import '../../../../../core/core.dart';
import '../dto/kyc_submission_dto.dart';
import 'admin_kyc_data_source.dart';

class AdminKycRemoteDataSource implements AdminKycDataSource {
  const AdminKycRemoteDataSource(this._api);

  final ApiClient _api;

  @override
  Future<List<KycSubmissionDto>> fetchPending() async => [
    for (final json in await _api.getItems('/admin/kyc'))
      KycSubmissionDto.fromJson(json),
  ];

  @override
  Future<Uint8List?> fetchImage(String userId, String slot) =>
      _api.getBytes('/admin/kyc/$userId/images/$slot');

  @override
  Future<KycSubmissionDto> submitDecision({
    required String userId,
    required bool isAccepted,
  }) async {
    final data = await _api.post(
      '/admin/kyc',
      body: {'userId': userId, 'isAccepted': isAccepted},
    );
    return KycSubmissionDto.fromJson(
      data is Map ? data.cast<String, dynamic>() : const {},
    );
  }
}
