import '../../../../../core/core.dart';
import '../entities/admin_queues.dart';
import '../repository/admin_queues_repository.dart';

class GetAdminQueues implements UseCase<AdminQueues, NoParams> {
  const GetAdminQueues(this._repository);

  final AdminQueuesRepository _repository;

  @override
  Future<AdminQueues> call(NoParams params) => _repository.getQueues();
}
