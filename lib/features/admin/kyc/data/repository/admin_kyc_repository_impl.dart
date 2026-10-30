import 'dart:typed_data';

import '../../../../../core/core.dart';
import '../../domain/entities/kyc_applicant.dart';
import '../../domain/repository/admin_kyc_repository.dart';
import '../data_sources/admin_kyc_data_source.dart';
import '../mappers/admin_kyc_mapper.dart';

class AdminKycRepositoryImpl implements AdminKycRepository {
  AdminKycRepositoryImpl(this._dataSource);

  final AdminKycDataSource _dataSource;

  /// The API has no single-record endpoint, so details come from the last
  /// fetched queue (refetched on a miss).
  final Map<String, KycApplicant> _cache = {};

  @override
  Future<Uint8List?> getImage(String userId, String slot) =>
      _dataSource.fetchImage(userId, slot);

  @override
  Future<List<KycApplicant>> getReviewQueue() async {
    final items = [
      for (final dto in await _dataSource.fetchPending()) dto.toEntity(),
    ];
    _cache
      ..clear()
      ..addEntries(items.map((a) => MapEntry(a.id, a)));
    return items;
  }

  @override
  Future<KycApplicant> getApplicant(String id) async {
    final cached = _cache[id];
    if (cached != null) return cached;
    await getReviewQueue();
    return _cache[id] ??
        (throw const ApiException(
          status: 404,
          code: ApiErrorCode.notFound,
          message: 'This review is no longer in the queue.',
        ));
  }

  @override
  Future<KycApplicant> submitDecision({
    required KycApplicant applicant,
    required KycDecision decision,
    required String reason,
  }) async {
    // `reason` has no API field yet; the audit log is written server-side.
    final dto = await _dataSource.submitDecision(
      userId: applicant.userId,
      isAccepted: decision == KycDecision.approve,
    );
    final mapped = kycStatusFromApi(dto.status);
    final status =
        mapped == KycReviewStatus.pending || mapped == KycReviewStatus.unknown
        ? (decision == KycDecision.approve
              ? KycReviewStatus.approved
              : KycReviewStatus.rejected)
        : mapped;
    final updated = applicant.copyWith(status: status, rawStatus: dto.status);
    _cache[applicant.id] = updated;
    return updated;
  }
}
