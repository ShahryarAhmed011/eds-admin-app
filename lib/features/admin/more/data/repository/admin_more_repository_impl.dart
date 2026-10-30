import '../../domain/entities/admin_profile.dart';
import '../../domain/repository/admin_more_repository.dart';
import '../data_sources/admin_more_data_source.dart';
import '../mappers/admin_profile_mapper.dart';

class AdminMoreRepositoryImpl implements AdminMoreRepository {
  const AdminMoreRepositoryImpl(this._dataSource);

  final AdminMoreDataSource _dataSource;

  /// The profile is required; the pending-requests count is optional.
  @override
  Future<AdminProfile> getProfile() async {
    final count = _dataSource.fetchPendingProductRequestCount().then<int?>(
      (n) => n,
      onError: (Object _) => null,
    );
    final profile = await _dataSource.fetchProfile();
    return profile.toEntity(pendingProductRequests: await count);
  }
}
