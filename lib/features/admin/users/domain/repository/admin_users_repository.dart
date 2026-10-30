import '../entities/admin_user.dart';

abstract interface class AdminUsersRepository {
  /// Max users per request (`limit`); the API has no cursor for this list.
  static const pageLimit = 50;

  /// [status] null means every status. [query] matches name, phone or ID.
  Future<List<AdminUser>> getUsers({AdminUserStatus? status, String? query});

  /// No single-user endpoint exists; served from the last fetched lists.
  Future<AdminUser> getUser(String id);

  /// Returns the user with the new status.
  Future<AdminUser> updateAccess({
    required AdminUser user,
    required AdminUserAccessAction action,
    required String reason,
  });
}
