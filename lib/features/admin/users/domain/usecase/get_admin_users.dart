import 'package:equatable/equatable.dart';

import '../../../../../core/core.dart';
import '../entities/admin_user.dart';
import '../repository/admin_users_repository.dart';

class GetAdminUsers implements UseCase<List<AdminUser>, AdminUsersQuery> {
  const GetAdminUsers(this._repository);

  final AdminUsersRepository _repository;

  @override
  Future<List<AdminUser>> call(AdminUsersQuery params) =>
      _repository.getUsers(status: params.status, query: params.query);
}

class AdminUsersQuery extends Equatable {
  const AdminUsersQuery({this.status, this.query});

  final AdminUserStatus? status;
  final String? query;

  @override
  List<Object?> get props => [status, query];
}
