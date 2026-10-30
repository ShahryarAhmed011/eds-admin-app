import 'dart:typed_data';

import '../../../../../core/core.dart';
import '../dto/kyc_submission_dto.dart';
import 'admin_kyc_data_source.dart';

/// Figma data in the `GET /admin/kyc` shape.
class AdminKycDummyDataSource implements AdminKycDataSource {
  List<Json> _rows() {
    final now = DateTime.now();
    String ago(Duration d) => now.subtract(d).toIso8601String();
    return [
      {
        'id': 'KYC-307',
        'userId': 'USR-131',
        'role': 'retailer',
        'nicNumber': '35202-9876441-0',
        'nameOnCard': 'Sana Malik',
        'issueDate': '2021-03-11',
        'expiryDate': '2031-03-11',
        'status': 'pending',
        'createdAt': ago(const Duration(hours: 26)),
        'updatedAt': ago(const Duration(hours: 26)),
        'phone': '+92 321 5550123',
        'shopLabel': 'Sana Kiryana · SH-019',
      },
      {
        'id': 'KYC-308',
        'userId': 'USR-142',
        'role': 'retailer',
        'nicNumber': '37405-1234567-1',
        'nameOnCard': 'Muhammad Ali',
        'issueDate': '2020-06-02',
        'expiryDate': '2030-06-02',
        'status': 'pending',
        'createdAt': ago(const Duration(minutes: 11)),
        'updatedAt': ago(const Duration(minutes: 11)),
        'phone': '+92 301 2345678',
        'shopLabel': 'Mehran General Store · SH-021',
      },
      {
        'id': 'KYC-309',
        'userId': 'USR-150',
        'role': 'rider',
        'nicNumber': '61101-8765210-9',
        'nameOnCard': 'Usman Ahmed',
        'issueDate': '2022-01-20',
        'expiryDate': '2032-01-20',
        'status': 'pending',
        'createdAt': ago(const Duration(minutes: 6)),
        'updatedAt': ago(const Duration(minutes: 6)),
        'phone': '+92 333 7654321',
      },
    ];
  }

  @override
  Future<List<KycSubmissionDto>> fetchPending() async {
    await dummyDelay();
    return [for (final row in _rows()) KycSubmissionDto.fromJson(row)];
  }

  @override
  Future<KycSubmissionDto> submitDecision({
    required String userId,
    required bool isAccepted,
  }) async {
    await dummyDelay();
    final row = _rows().firstWhere(
      (r) => r['userId'] == userId,
      orElse: () => throw const ApiException(
        status: 404,
        code: ApiErrorCode.notFound,
        message: 'No KYC record for that account.',
      ),
    );
    return KycSubmissionDto.fromJson({
      ...row,
      'status': isAccepted ? 'approved' : 'rejected',
      'updatedAt': DateTime.now().toIso8601String(),
    });
  }

  @override
  Future<Uint8List?> fetchImage(String userId, String slot) async => null;
}
