import 'dart:convert';

import '../../../../core/core.dart';
import '../domain/kyc_record.dart';
import '../domain/kyc_repository.dart';

/// `GET` / `POST` / `PUT /kyc`, the same for retailers and riders.
class KycRepositoryImpl implements KycRepository {
  KycRepositoryImpl(this._api, this._onboarding, this._cache);

  final ApiClient _api;
  final OnboardingTracker _onboarding;
  final SessionCache _cache;

  static const _path = '/kyc';

  @override
  Future<KycRecord> getRecord() async {
    try {
      final record = _toRecord(await _api.getObject(_path));
      if (record.status == KycStatus.approved) {
        await _onboarding.completeOnboarding(OnboardingStep.kyc);
      }
      return record;
    } on ApiException catch (e) {
      // Nothing submitted yet.
      if (e.status == 404) return const KycRecord();
      rethrow;
    }
  }

  @override
  Future<KycRecord> submit(KycSubmission submission) async {
    final existing = await getRecord();
    final body = {
      'nicNumber': submission.nicNumber,
      'nameOnCard': submission.nameOnCard.trim(),
      'issueDate': _date(submission.issueDate),
      'expiryDate': _date(submission.expiryDate),
      for (final MapEntry(:key, :value) in submission.images.entries)
        key.field: base64Encode(value),
    };
    final data = existing.status == KycStatus.notSubmitted
        ? await _api.post(_path, body: body)
        : await _api.put(_path, body: body);
    return _toRecord(data is Map ? data.cast<String, dynamic>() : body);
  }

  /// From the device only: the profile copy when the app keeps one, else
  /// the login `user` block, which is always cached. Nothing is fetched;
  /// with neither, the field just starts empty.
  @override
  Future<String> profileName() async {
    final profile =
        await _cache.read(SessionCacheKeys.profile) ??
        await _cache.read(SessionCacheKeys.user);
    return [
      profile?.str('firstName'),
      profile?.str('lastName'),
    ].whereType<String>().where((part) => part.isNotEmpty).join(' ');
  }

  static KycRecord _toRecord(Json json) => KycRecord(
    status: KycStatus.fromCode(json.str('status') ?? 'pending'),
    nicNumber: json.strOr('nicNumber'),
    nameOnCard: json.strOr('nameOnCard'),
    issueDate: json.date('issueDate'),
    expiryDate: json.date('expiryDate'),
    reason: json.str('rejectionReason') ?? json.str('statusReason'),
    images: KycImageSlot.decodeAll(json),
  );

  static String _date(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}-'
      '${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';
}
