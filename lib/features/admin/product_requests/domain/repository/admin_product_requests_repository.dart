import '../entities/admin_product_request.dart';

abstract interface class AdminProductRequestsRepository {
  Future<ProductRequestsPage> getRequests(ProductRequestStatus status);

  Future<ProductRequestDetail> getRequest(String id);

  /// Approving creates the catalogue variant first, then approves the
  /// request against it. Returns the saved status.
  Future<ProductRequestStatus> submitDecision({
    required ProductRequestDetail request,
    required ProductRequestDecision decision,
    required String reason,
  });
}
