import '../../../../../core/core.dart';
import '../dto/admin_queue_counts_dto.dart';
import 'admin_queues_data_source.dart';

/// Figma counts, built from API-shaped item lists.
class AdminQueuesDummyDataSource implements AdminQueuesDataSource {
  @override
  Future<AdminQueueCountsDto> fetchCounts() async {
    await dummyDelay();
    final now = DateTime.now();
    final kyc = [
      for (var i = 0; i < 12; i++)
        <String, dynamic>{
          'id': 'KYC-${300 + i}',
          'role': i < 8 ? 'retailer' : 'rider',
          'status': 'pending',
          // Oldest is 26h.
          'createdAt': now
              .subtract(Duration(hours: i == 0 ? 26 : 12 - i))
              .toIso8601String(),
        },
    ];
    List<Json> rows(int n) => [
      for (var i = 0; i < n; i++) <String, dynamic>{'id': '$i'},
    ];
    return AdminQueueCountsDto.fromResponses(
      kyc: kyc,
      readyShops: rows(5),
      flaggedUsers: rows(3),
      productRequests: rows(7),
      catalogueVariantCount: 4,
      region: 'Islamabad operations',
    );
  }
}
