import '../../../../../core/core.dart';
import '../entities/admin_shop.dart';
import '../repository/admin_shops_repository.dart';

class GetAdminShop implements UseCase<AdminShop, String> {
  const GetAdminShop(this._repository);

  final AdminShopsRepository _repository;

  @override
  Future<AdminShop> call(String id) => _repository.getShop(id);
}
