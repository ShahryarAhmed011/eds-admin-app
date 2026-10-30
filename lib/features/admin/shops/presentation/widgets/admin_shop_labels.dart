import '../../../../../core/core.dart';
import '../../../common/admin_common.dart';
import '../../domain/entities/admin_shop.dart';

/// One row of the "Readiness checks" card.
typedef ShopReadinessCheck = ({String title, String detail, bool passed});

extension AdminShopUi on AdminShop {
  String get badgeLabel => switch (status) {
    AdminShopStatus.draft => 'Draft',
    AdminShopStatus.kycReview => 'KYC review',
    AdminShopStatus.approved => 'Approved',
    AdminShopStatus.live => 'Live',
    AdminShopStatus.paused => 'Paused',
    AdminShopStatus.flagged => 'Flagged',
    AdminShopStatus.suspended => 'Suspended',
    AdminShopStatus.closed => 'Closed',
    AdminShopStatus.unknown => AdminFormat.humanize(rawStatus),
  };

  EdsTone get badgeTone => switch (status) {
    AdminShopStatus.approved || AdminShopStatus.live => EdsTone.success,
    AdminShopStatus.kycReview ||
    AdminShopStatus.paused ||
    AdminShopStatus.flagged => EdsTone.warning,
    AdminShopStatus.suspended => EdsTone.danger,
    AdminShopStatus.draft ||
    AdminShopStatus.closed ||
    AdminShopStatus.unknown => EdsTone.neutral,
  };

  /// "SH-021 · G-11/3 · 48 listings".
  String get listSubtitle => [
    reference,
    ?(areaName ?? landmark),
    '$productCount listings',
  ].join(' · ');

  /// Owner name when known, otherwise the owner's account id.
  String get ownerLabel => ownerName ?? 'Owner $ownerUserId';

  /// Derived from the API record (KYC state, product count, area).
  List<ShopReadinessCheck> get readinessChecks => [
    (
      title: isKycApproved ? 'KYC approved' : 'KYC not approved yet',
      detail:
          kycReviewLabel ??
          (isKycApproved
              ? 'Identity review complete'
              : 'Awaiting identity review'),
      passed: isKycApproved,
    ),
    (
      title: '$productCount complete listings',
      detail: productCount > 0
          ? 'Prices and stock validated'
          : 'Add products before going live',
      passed: productCount > 0,
    ),
    (
      title: areaName != null
          ? '$areaName is serviceable'
          : (areaId != null ? 'Service area set' : 'No service area'),
      detail:
          landmark ??
          (areaId != null ? 'Area #$areaId' : 'Set by the retailer'),
      passed: areaId != null,
    ),
  ];

  /// Visibility banner shown at the bottom of the shop detail.
  (String, String, EdsTone) get visibilityBanner {
    final (title, message, tone) = switch (status) {
      AdminShopStatus.approved => (
        'Not live yet',
        'Set live to make the shop and available products visible to '
            'nearby customers.',
        EdsTone.warning,
      ),
      AdminShopStatus.draft || AdminShopStatus.kycReview => (
        'Not ready yet',
        'The retailer must finish onboarding before the shop can go live.',
        EdsTone.neutral,
      ),
      AdminShopStatus.live => (
        'Live',
        'The shop and its available products are visible to nearby '
            'customers.',
        EdsTone.success,
      ),
      AdminShopStatus.paused => (
        'Paused by the retailer',
        'Hidden from customers until the retailer resumes it.',
        EdsTone.warning,
      ),
      AdminShopStatus.flagged => (
        'Flagged for review',
        'The shop stays visible until you decide on the open complaints.',
        EdsTone.warning,
      ),
      AdminShopStatus.suspended => (
        'Suspended',
        'Hidden from customers pending review.',
        EdsTone.danger,
      ),
      AdminShopStatus.closed => (
        'Closed',
        'This shop is permanently closed and hidden from customers.',
        EdsTone.neutral,
      ),
      AdminShopStatus.unknown => (
        badgeLabel,
        'Check the shop status before making changes.',
        EdsTone.neutral,
      ),
    };
    final reason = statusReason;
    return (
      title,
      reason == null ? message : '$message\nReason: $reason',
      tone,
    );
  }
}
