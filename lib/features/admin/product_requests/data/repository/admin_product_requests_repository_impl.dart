import '../../domain/entities/admin_product_request.dart';
import '../../domain/repository/admin_product_requests_repository.dart';
import '../data_sources/admin_product_requests_data_source.dart';
import '../dto/product_request_dto.dart';
import '../mappers/product_request_mapper.dart';

class AdminProductRequestsRepositoryImpl
    implements AdminProductRequestsRepository {
  const AdminProductRequestsRepositoryImpl(this._dataSource);

  final AdminProductRequestsDataSource _dataSource;

  @override
  Future<ProductRequestsPage> getRequests(ProductRequestStatus status) async =>
      (await _dataSource.fetchRequests(status.name)).toEntity();

  @override
  Future<ProductRequestDetail> getRequest(String id) async =>
      (await _dataSource.fetchRequest(id)).toDetail();

  @override
  Future<ProductRequestStatus> submitDecision({
    required ProductRequestDetail request,
    required ProductRequestDecision decision,
    required String reason,
  }) async {
    final id = request.summary.id;
    final saved = switch (decision) {
      ProductRequestDecision.reject => await _dataSource.reject(
        id,
        reason: reason,
      ),
      // The approve endpoint takes no reason; it is kept in the sheet for
      // the audit trail once the API accepts one.
      ProductRequestDecision.approve => await _approve(request),
    };
    return saved.status == null
        ? (decision == ProductRequestDecision.approve
              ? ProductRequestStatus.approved
              : ProductRequestStatus.rejected)
        : parseRequestStatus(saved.status);
  }

  /// "Approve · Create new variant": create the variant, then resolve the
  /// request to it. If the pack size can't be parsed the server resolves it.
  Future<ProductRequestDto> _approve(ProductRequestDetail request) async {
    final body = createVariantBody(request);
    final variantId = body == null
        ? null
        : await _dataSource.createVariant(body);
    return _dataSource.approve(
      request.summary.id,
      resolvedVariantId: variantId == null || variantId.isEmpty
          ? null
          : variantId,
      duplicate: false,
    );
  }
}
