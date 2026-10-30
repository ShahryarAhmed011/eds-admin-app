import '../../../../../core/core.dart';
import '../dto/product_request_dto.dart';

abstract interface class AdminProductRequestsDataSource {
  /// [status] is `pending`, `approved` or `rejected`.
  Future<ProductRequestsPageDto> fetchRequests(String status);

  Future<ProductRequestDto> fetchRequest(String id);

  /// Creates a global catalogue variant and returns its id.
  Future<String> createVariant(Json body);

  Future<ProductRequestDto> approve(
    String id, {
    String? resolvedVariantId,
    required bool duplicate,
  });

  Future<ProductRequestDto> reject(String id, {required String reason});
}
