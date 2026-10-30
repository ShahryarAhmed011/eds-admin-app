import '../../../../../core/core.dart';
import '../entities/admin_shop.dart';
import '../repository/admin_shops_repository.dart';

class GetAdminShops implements UseCase<List<AdminShop>, AdminShopsFilter> {
  const GetAdminShops(this._repository);

  final AdminShopsRepository _repository;

  @override
  Future<List<AdminShop>> call(AdminShopsFilter params) =>
      _repository.getShops(params);
}
