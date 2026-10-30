import '../../../../../core/core.dart';
import '../dto/product_request_dto.dart';
import 'admin_product_requests_data_source.dart';

class AdminProductRequestsRemoteDataSource
    implements AdminProductRequestsDataSource {
  const AdminProductRequestsRemoteDataSource(this._api);

  final ApiClient _api;

  static const _statuses = ['pending', 'approved', 'rejected'];

  /// `GET /admin/product-requests?status=&limit=20`.
  @override
  Future<ProductRequestsPageDto> fetchRequests(String status) async {
    final data = await _api.get(
      '/admin/product-requests',
      query: {'status': status, 'limit': 20},
    );
    return ProductRequestsPageDto.fromJson(
      data is Map ? data.cast<String, dynamic>() : const {},
      status: status,
    );
  }

  /// There is no detail endpoint; find the request in the status lists.
  @override
  Future<ProductRequestDto> fetchRequest(String id) async {
    for (final status in _statuses) {
      final page = await fetchRequests(status);
      final match = page.items.where((r) => r.id == id).firstOrNull;
      if (match != null) return match;
    }
    throw const ApiException(
      status: 404,
      code: ApiErrorCode.notFound,
      message: 'This product request could not be found.',
    );
  }

  /// `POST /admin/catalog/variants` → `variant_id`.
  @override
  Future<String> createVariant(Json body) async {
    final data = await _api.post('/admin/catalog/variants', body: body);
    return data is Map ? data.cast<String, dynamic>().id('variantId') : '';
  }

  /// `POST /admin/product-requests/{id}/approve`.
  @override
  Future<ProductRequestDto> approve(
    String id, {
    String? resolvedVariantId,
    required bool duplicate,
  }) async => _request(
    id,
    await _api.post(
      '/admin/product-requests/$id/approve',
      body: {'resolvedVariantId': ?resolvedVariantId, 'duplicate': duplicate},
    ),
  );

  /// `POST /admin/product-requests/{id}/reject`.
  @override
  Future<ProductRequestDto> reject(String id, {required String reason}) async =>
      _request(
        id,
        await _api.post(
          '/admin/product-requests/$id/reject',
          body: {'reason': reason},
        ),
      );

  ProductRequestDto _request(String id, Object? data) =>
      ProductRequestDto.fromJson(
        data is Map ? data.cast<String, dynamic>() : {'id': id},
      );
}
