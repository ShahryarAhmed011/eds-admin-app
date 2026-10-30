import '../../../../../core/core.dart';
import '../dto/admin_profile_dto.dart';
import 'admin_more_data_source.dart';

class AdminMoreRemoteDataSource implements AdminMoreDataSource {
  const AdminMoreRemoteDataSource(this._api);

  final ApiClient _api;

  @override
  Future<AdminProfileDto> fetchProfile() async =>
      AdminProfileDto.fromJson(await _api.getObject('/profile'));

  @override
  Future<int> fetchPendingProductRequestCount() async => (await _api.getItems(
    '/admin/product-requests',
    query: {'status': 'pending', 'limit': 100},
  )).length;
}
