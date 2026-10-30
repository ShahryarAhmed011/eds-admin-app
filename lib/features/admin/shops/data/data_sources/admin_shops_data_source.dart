import '../dto/admin_shop_dto.dart';

abstract interface class AdminShopsDataSource {
  /// `GET /admin/stores?status=&limit=`.
  Future<List<AdminShopDto>> fetchShops({String? status, int limit = 50});

  /// `PATCH /admin/stores/{id}/status` `{status, reason}`.
  Future<AdminShopDto> updateStatus({
    required String id,
    required String status,
    required String reason,
  });
}
