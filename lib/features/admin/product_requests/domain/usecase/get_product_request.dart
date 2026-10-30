import '../../../../../core/core.dart';
import '../entities/admin_product_request.dart';
import '../repository/admin_product_requests_repository.dart';

class GetProductRequest implements UseCase<ProductRequestDetail, String> {
  const GetProductRequest(this._repository);

  final AdminProductRequestsRepository _repository;

  @override
  Future<ProductRequestDetail> call(String id) => _repository.getRequest(id);
}
