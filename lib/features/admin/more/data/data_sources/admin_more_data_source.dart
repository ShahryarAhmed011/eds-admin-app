import '../dto/admin_profile_dto.dart';

abstract interface class AdminMoreDataSource {
  /// `GET /profile`.
  Future<AdminProfileDto> fetchProfile();

  /// `GET /admin/product-requests?status=pending` item count.
  Future<int> fetchPendingProductRequestCount();
}
