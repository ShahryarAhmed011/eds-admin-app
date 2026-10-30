import '../entities/admin_shop.dart';

/// Which shops a list shows.
enum AdminShopsFilter { all, ready, needsAttention }

abstract interface class AdminShopsRepository {
  /// Max shops per request (`limit`); the API has no cursor for this list.
  static const pageLimit = 50;

  Future<List<AdminShop>> getShops(AdminShopsFilter filter);

  /// No single-shop endpoint exists; served from the last fetched lists.
  Future<AdminShop> getShop(String id);

  /// Returns the shop with the new status.
  Future<AdminShop> updateStatus({
    required AdminShop shop,
    required AdminShopStatusAction action,
    required String reason,
  });
}
