import '../../../../../core/core.dart';
import '../entities/admin_product_request.dart';
import '../repository/admin_product_requests_repository.dart';

class GetProductRequestsPage
    implements UseCase<ProductRequestsPage, ProductRequestStatus> {
  const GetProductRequestsPage(this._repository);

  final AdminProductRequestsRepository _repository;

  @override
  Future<ProductRequestsPage> call(ProductRequestStatus status) =>
      _repository.getRequests(status);
}
