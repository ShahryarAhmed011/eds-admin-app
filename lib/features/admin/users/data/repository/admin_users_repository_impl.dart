import '../../../../../core/core.dart';
import '../../domain/entities/admin_user.dart';
import '../../domain/repository/admin_users_repository.dart';
import '../data_sources/admin_users_data_source.dart';
import '../mappers/admin_user_mapper.dart';

class AdminUsersRepositoryImpl implements AdminUsersRepository {
  AdminUsersRepositoryImpl(this._dataSource);

  final AdminUsersDataSource _dataSource;
  final Map<String, AdminUser> _cache = {};

  @override
  Future<List<AdminUser>> getUsers({
    AdminUserStatus? status,
    String? query,
  }) async {
    final users = [
      for (final dto in await _dataSource.fetchUsers(
        status: adminUserStatusToApi(status),
        query: query,
        limit: AdminUsersRepository.pageLimit,
      ))
        dto.toEntity(),
    ];
    for (final u in users) {
      _cache[u.id] = u;
    }
    return users;
  }

  @override
  Future<AdminUser> getUser(String id) async {
    final cached = _cache[id];
    if (cached != null) return cached;
    await getUsers(query: id);
    return _cache[id] ??
        (throw const ApiException(
          status: 404,
          code: ApiErrorCode.notFound,
          message: 'This user could not be found.',
        ));
  }

  @override
  Future<AdminUser> updateAccess({
    required AdminUser user,
    required AdminUserAccessAction action,
    required String reason,
  }) async {
    final dto = await _dataSource.updateStatus(
      id: user.id,
      status: adminUserActionToApi(action),
      reason: reason,
    );
    final updated = dto.toEntity().mergeFrom(user);
    _cache[user.id] = updated;
    return updated;
  }
}
