import '../../../../../core/core.dart';
import '../dto/admin_shop_dto.dart';
import 'admin_shops_data_source.dart';

class AdminShopsRemoteDataSource implements AdminShopsDataSource {
  const AdminShopsRemoteDataSource(this._api);

  final ApiClient _api;

  @override
  Future<List<AdminShopDto>> fetchShops({
    String? status,
    int limit = 50,
  }) async => [
    for (final json in await _api.getItems(
      '/admin/stores',
      query: {'status': status, 'limit': limit},
    ))
      AdminShopDto.fromJson(json),
  ];

  @override
  Future<AdminShopDto> updateStatus({
    required String id,
    required String status,
    required String reason,
  }) async {
    final data = await _api.patch(
      '/admin/stores/$id/status',
      body: {'status': status, 'reason': reason},
    );
    return AdminShopDto.fromJson(
      data is Map ? data.cast<String, dynamic>() : const {},
    );
  }
}
