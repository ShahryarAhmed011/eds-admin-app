import 'package:equatable/equatable.dart';

/// [approved] = KYC approved and ready for activation.
/// [unknown] covers any status string the app doesn't know yet.
enum AdminShopStatus {
  draft,
  kycReview,
  approved,
  live,
  paused,
  flagged,
  suspended,
  closed,
  unknown,
}

/// Decision taken from the "Change shop status" sheet.
enum AdminShopStatusAction { setLive, suspend, close }

class AdminShop extends Equatable {
  const AdminShop({
    required this.id,
    required this.name,
    required this.ownerUserId,
    required this.categoryCode,
    required this.status,
    required this.rawStatus,
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

  final String id;
  final String name;
  final String ownerUserId;
  final String categoryCode;
  final AdminShopStatus status;

  /// Status as sent by the API, for labelling unknown values.
  final String rawStatus;
  final int productCount;
  final String? statusReason;
  final String? areaId;
  final String? landmark;
  final DateTime? createdAt;

  // Not provided by the API yet (null from remote).
  final String? ownerName;
  final String? phone;
  final String? areaName;
  final String? kycReviewLabel;
  final String? hoursLabel;
  final String? pinLabel;
  final String? updatedLabel;

  /// "SH-021" for display, whatever the id format.
  String get reference => RegExp(r'^[A-Za-z]').hasMatch(id) ? id : 'SH-$id';

  /// Identity review has been passed.
  bool get isKycApproved => switch (status) {
    AdminShopStatus.draft ||
    AdminShopStatus.kycReview ||
    AdminShopStatus.unknown => false,
    _ => true,
  };

  /// Keeps the Figma-only extras when the API returns a bare record.
  AdminShop mergeFrom(AdminShop previous) => AdminShop(
    id: id,
    name: name.isEmpty ? previous.name : name,
    ownerUserId: ownerUserId.isEmpty ? previous.ownerUserId : ownerUserId,
    categoryCode: categoryCode.isEmpty ? previous.categoryCode : categoryCode,
    status: status,
    rawStatus: rawStatus,
    productCount: productCount,
    statusReason: statusReason,
    areaId: areaId ?? previous.areaId,
    landmark: landmark ?? previous.landmark,
    createdAt: createdAt ?? previous.createdAt,
    ownerName: ownerName ?? previous.ownerName,
    phone: phone ?? previous.phone,
    areaName: areaName ?? previous.areaName,
    kycReviewLabel: kycReviewLabel ?? previous.kycReviewLabel,
    hoursLabel: hoursLabel ?? previous.hoursLabel,
    pinLabel: pinLabel ?? previous.pinLabel,
    updatedLabel: updatedLabel ?? previous.updatedLabel,
  );

  @override
  List<Object?> get props => [
    id,
    name,
    ownerUserId,
    categoryCode,
    status,
    rawStatus,
    productCount,
    statusReason,
    areaId,
    landmark,
    createdAt,
    ownerName,
    phone,
    areaName,
    kycReviewLabel,
    hoursLabel,
    pinLabel,
    updatedLabel,
  ];
}
