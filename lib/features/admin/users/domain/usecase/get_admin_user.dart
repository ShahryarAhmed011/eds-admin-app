import '../../../../../core/core.dart';
import '../entities/admin_user.dart';
import '../repository/admin_users_repository.dart';

class GetAdminUser implements UseCase<AdminUser, String> {
  const GetAdminUser(this._repository);

  final AdminUsersRepository _repository;

  @override
  Future<AdminUser> call(String id) => _repository.getUser(id);
}
