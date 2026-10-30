import '../../domain/entities/admin_queues.dart';
import '../../domain/repository/admin_queues_repository.dart';
import '../data_sources/admin_queues_data_source.dart';
import '../mappers/admin_queues_mapper.dart';

class AdminQueuesRepositoryImpl implements AdminQueuesRepository {
  const AdminQueuesRepositoryImpl(this._dataSource);

  final AdminQueuesDataSource _dataSource;

  @override
  Future<AdminQueues> getQueues() async =>
      (await _dataSource.fetchCounts()).toEntity(refreshedAt: DateTime.now());
}
