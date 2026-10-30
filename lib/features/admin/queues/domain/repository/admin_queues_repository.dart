import '../entities/admin_queues.dart';

abstract interface class AdminQueuesRepository {
  Future<AdminQueues> getQueues();
}
