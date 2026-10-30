import 'dart:typed_data';

import 'package:eds_admin_app/features/admin/kyc/data/data_sources/admin_kyc_data_source.dart';
import 'package:eds_admin_app/features/admin/kyc/data/dto/kyc_submission_dto.dart';
import 'package:eds_admin_app/features/admin/kyc/data/mappers/admin_kyc_mapper.dart';
import 'package:eds_admin_app/features/admin/kyc/data/repository/admin_kyc_repository_impl.dart';
import 'package:eds_admin_app/features/admin/kyc/domain/entities/kyc_applicant.dart';
import 'package:eds_admin_app/core/core.dart';
import 'package:flutter_test/flutter_test.dart';

// GET /admin/kyc item, field names from docs/api/curl-reference.md.
const _row = {
  'id': 41,
  'userId': 1207,
  'role': 'retailer',
  'nicNumber': '37405-1234567-1',
  'nameOnCard': 'Muhammad Ali',
  'issueDate': '2020-06-02',
  'expiryDate': '2030-06-02',
  'status': 'pending',
  'createdAt': '2026-10-16T09:30:00Z',
  'updatedAt': '2026-10-16T09:30:00Z',
};

class _FakeSource implements AdminKycDataSource {
  _FakeSource(this.responseStatus);

  final String responseStatus;
  String? sentUserId;
  bool? sentAccepted;

  @override
  Future<Uint8List?> fetchImage(String userId, String slot) async => null;

  @override
  Future<List<KycSubmissionDto>> fetchPending() async => [
    KycSubmissionDto.fromJson(_row),
  ];

  @override
  Future<KycSubmissionDto> submitDecision({
    required String userId,
    required bool isAccepted,
  }) async {
    sentUserId = userId;
    sentAccepted = isAccepted;
    return KycSubmissionDto.fromJson({..._row, 'status': responseStatus});
  }
}

void main() {
  test('maps an API row, keeping only the last four NIC digits', () {
    final a = KycSubmissionDto.fromJson(_row).toEntity();
    expect(a.id, '41');
    expect(a.userId, '1207');
    expect(a.reference, 'KYC-41');
    expect(a.role, KycApplicantRole.retailer);
    expect(a.status, KycReviewStatus.pending);
    expect(a.cnicLast4, '5671');
    expect(a.props.contains('37405-1234567-1'), isFalse);
    expect(a.submittedAt, DateTime.utc(2026, 10, 16, 9, 30));
    expect(a.phone, isNull);
    expect(a.isOverdue(DateTime.utc(2026, 10, 17, 10)), isTrue);
    expect(a.isOverdue(DateTime.utc(2026, 10, 16, 10)), isFalse);
  });

  test('unknown status and role map defensively', () {
    final a = KycSubmissionDto.fromJson({
      'id': 1,
      'status': 'escalated',
      'role': 'wholesaler',
    }).toEntity();
    expect(a.status, KycReviewStatus.unknown);
    expect(a.rawStatus, 'escalated');
    expect(a.role, KycApplicantRole.other);
    expect(a.cnicLast4, '—');
  });

  test('decision posts user_id + is_accepted and updates status', () async {
    final source = _FakeSource('approved');
    final repo = AdminKycRepositoryImpl(source);
    final applicant = await repo.getApplicant('41');
    final updated = await repo.submitDecision(
      applicant: applicant,
      decision: KycDecision.approve,
      reason: 'Clear photos.',
    );
    expect(source.sentUserId, '1207');
    expect(source.sentAccepted, isTrue);
    expect(updated.status, KycReviewStatus.approved);
  });

  test('decision falls back to the requested verdict on odd status', () async {
    final repo = AdminKycRepositoryImpl(_FakeSource('???'));
    final applicant = await repo.getApplicant('41');
    final updated = await repo.submitDecision(
      applicant: applicant,
      decision: KycDecision.reject,
      reason: 'Blurred.',
    );
    expect(updated.status, KycReviewStatus.rejected);
  });

  test('unknown id is a not-found error, never fallback data', () {
    expect(
      AdminKycRepositoryImpl(_FakeSource('pending')).getApplicant('nope'),
      throwsA(
        isA<ApiException>().having(
          (e) => e.code,
          'code',
          ApiErrorCode.notFound,
        ),
      ),
    );
  });
}
