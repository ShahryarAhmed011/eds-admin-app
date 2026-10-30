import '../../../../../core/core.dart';
import '../dto/admin_user_dto.dart';
import 'admin_users_data_source.dart';

class AdminUsersRemoteDataSource implements AdminUsersDataSource {
  const AdminUsersRemoteDataSource(this._api);

  final ApiClient _api;

  @override
  Future<List<AdminUserDto>> fetchUsers({
    String? status,
    String? role,
    String? query,
    int limit = 50,
  }) async => [
    for (final json in await _api.getItems(
      '/admin/users',
      query: {
        'status': status,
        'role': role,
        'q': (query == null || query.trim().isEmpty) ? null : query.trim(),
        'limit': limit,
      },
    ))
      AdminUserDto.fromJson(json),
  ];

  @override
  Future<AdminUserDto> updateStatus({
    required String id,
    required String status,
    required String reason,
  }) async {
    final data = await _api.patch(
      '/admin/users/$id/status',
      body: {'status': status, 'reason': reason},
    );
    return AdminUserDto.fromJson(
      data is Map ? data.cast<String, dynamic>() : const {},
    );
  }
}
