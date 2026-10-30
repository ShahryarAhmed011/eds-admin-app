import '../dto/admin_user_dto.dart';

abstract interface class AdminUsersDataSource {
  /// `GET /admin/users?role=&status=&q=&limit=`.
  Future<List<AdminUserDto>> fetchUsers({
    String? status,
    String? role,
    String? query,
    int limit = 50,
  });

  /// `PATCH /admin/users/{id}/status` `{status, reason}`.
  Future<AdminUserDto> updateStatus({
    required String id,
    required String status,
    required String reason,
  });
}
