import '../../../../../core/core.dart';

/// One shop from `GET /admin/stores` / `PATCH /admin/stores/{id}/status`.
///
/// Fields after [createdAt] are not provided by the API yet; only the dummy
/// data source fills them (Figma copy). They are null from remote.
class AdminShopDto {
  const AdminShopDto({
    required this.id,
    required this.name,
    required this.slug,
    required this.ownerUserId,
    required this.categoryCode,
    required this.status,
    required this.productCount,
    this.statusReason,
    this.areaId,
    this.landmark,
    this.createdAt,
    this.ownerName,
    this.phone,
    this.areaName,
    this.kycReviewLabel,
    this.hoursLabel,
    this.pinLabel,
    this.updatedLabel,
  });

  factory AdminShopDto.fromJson(Json json) => AdminShopDto(
    id: json.id(),
    name: json.strOr('name'),
    slug: json.strOr('slug'),
    ownerUserId: json.id('ownerUserId'),
    categoryCode: json.strOr('categoryCode'),
    status: json.strOr('status'),
    statusReason: json.str('statusReason'),
    productCount: json.integer('productCount') ?? 0,
    areaId: json.str('areaId'),
    landmark: json.str('landmark'),
    createdAt: json.date('createdAt'),
    ownerName: json.str('ownerName'),
    phone: json.str('phone'),
    areaName: json.str('areaName'),
    kycReviewLabel: json.str('kycReviewLabel'),
    hoursLabel: json.str('hoursLabel'),
    pinLabel: json.str('pinLabel'),
    updatedLabel: json.str('updatedLabel'),
  );

  final String id;
  final String name;
  final String slug;
  final String ownerUserId;
  final String categoryCode;
  final String status;
  final String? statusReason;
  final int productCount;
  final String? areaId;
  final String? landmark;
  final DateTime? createdAt;

  // Not in the API yet.
  final String? ownerName;
  final String? phone;
  final String? areaName;
  final String? kycReviewLabel;
  final String? hoursLabel;
  final String? pinLabel;
  final String? updatedLabel;
}

/// Status strings sent to / filtered on the API. The API does not document
/// its shop status set; these are the values this app assumes.
abstract final class AdminShopApiStatus {
  static const ready = 'kyc_approved';
  static const live = 'live';
  static const flagged = 'flagged';
  static const suspended = 'suspended';
  static const closed = 'closed';
}
