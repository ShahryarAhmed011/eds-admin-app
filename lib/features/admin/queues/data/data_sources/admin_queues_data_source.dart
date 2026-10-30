import '../dto/admin_queue_counts_dto.dart';

abstract interface class AdminQueuesDataSource {
  /// Counts every review queue. Individual failures are tolerated (that
  /// queue's count is null); throws only when every call fails.
  Future<AdminQueueCountsDto> fetchCounts();
}
