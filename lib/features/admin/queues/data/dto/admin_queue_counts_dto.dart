import '../../../../../core/core.dart';

/// Aggregated queue sizes, built from the item lists of several admin
/// endpoints. A null list means that call failed (tolerated).
class AdminQueueCountsDto {
  const AdminQueueCountsDto({
    this.kycItems,
    this.readyShopItems,
    this.flaggedUserItems,
    this.productRequestItems,
    this.catalogueVariantCount,
    this.region,
  });

  /// Builds from the raw `data.items` of each endpoint.
  factory AdminQueueCountsDto.fromResponses({
    List<Json>? kyc,
    List<Json>? readyShops,
    List<Json>? flaggedUsers,
    List<Json>? productRequests,
    int? catalogueVariantCount,
    String? region,
  }) => AdminQueueCountsDto(
    kycItems: kyc?.map(KycQueueItemDto.fromJson).toList(),
    readyShopItems: readyShops?.length,
    flaggedUserItems: flaggedUsers?.length,
    productRequestItems: productRequests?.length,
    catalogueVariantCount: catalogueVariantCount,
    region: region,
  );

  /// `GET /admin/kyc` rows (only role and age are used).
  final List<KycQueueItemDto>? kycItems;

  /// `GET /admin/stores?status=kyc_approved` count.
  final int? readyShopItems;

  /// `GET /admin/users?status=flagged` count.
  final int? flaggedUserItems;

  /// `GET /admin/product-requests?status=pending` count.
  final int? productRequestItems;

  /// No admin endpoint lists catalogue variants needing review yet; only the
  /// dummy data source fills this.
  final int? catalogueVariantCount;

  /// Not in the API (Figma copy); null from remote.
  final String? region;
}

class KycQueueItemDto {
  const KycQueueItemDto({required this.role, this.createdAt});

  factory KycQueueItemDto.fromJson(Json json) => KycQueueItemDto(
    role: json.strOr('role'),
    createdAt: json.date('createdAt'),
  );

  final String role;
  final DateTime? createdAt;
}
