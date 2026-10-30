import '../../domain/entities/admin_shop.dart';
import '../dto/admin_shop_dto.dart';

extension AdminShopDtoMapper on AdminShopDto {
  AdminShop toEntity() => AdminShop(
    id: id,
    name: name.trim().isEmpty ? slug : name.trim(),
    ownerUserId: ownerUserId,
    categoryCode: categoryCode,
    status: adminShopStatusFromApi(status),
    rawStatus: status,
    productCount: productCount,
    statusReason: (statusReason?.trim().isEmpty ?? true)
        ? null
        : statusReason!.trim(),
    areaId: areaId,
    landmark: landmark,
    createdAt: createdAt,
    ownerName: ownerName,
    phone: phone,
    areaName: areaName,
    kycReviewLabel: kycReviewLabel,
    hoursLabel: hoursLabel,
    pinLabel: pinLabel,
    updatedLabel: updatedLabel,
  );
}

AdminShopStatus adminShopStatusFromApi(String raw) => switch (raw
    .toLowerCase()) {
  'draft' => AdminShopStatus.draft,
  'kyc_under_review' || 'kyc_pending' || 'pending' => AdminShopStatus.kycReview,
  'kyc_approved' || 'approved' || 'ready' => AdminShopStatus.approved,
  'live' || 'active' => AdminShopStatus.live,
  'paused' => AdminShopStatus.paused,
  'flagged' => AdminShopStatus.flagged,
  'suspended' || 'disabled' => AdminShopStatus.suspended,
  'closed' => AdminShopStatus.closed,
  _ => AdminShopStatus.unknown,
};

/// API status string an action sets.
String adminShopActionToApi(AdminShopStatusAction action) => switch (action) {
  AdminShopStatusAction.setLive => AdminShopApiStatus.live,
  AdminShopStatusAction.suspend => AdminShopApiStatus.suspended,
  AdminShopStatusAction.close => AdminShopApiStatus.closed,
};
