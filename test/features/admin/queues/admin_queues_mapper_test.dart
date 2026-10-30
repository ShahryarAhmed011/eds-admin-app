import 'package:eds_admin_app/features/admin/queues/data/dto/admin_queue_counts_dto.dart';
import 'package:eds_admin_app/features/admin/queues/data/mappers/admin_queues_mapper.dart';
import 'package:eds_admin_app/features/admin/queues/domain/entities/admin_queues.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('counts queues and tolerates failed calls', () {
    final dto = AdminQueueCountsDto.fromResponses(
      kyc: const [
        {'id': 1, 'role': 'retailer', 'createdAt': '2026-10-15T08:00:00Z'},
        {'id': 2, 'role': 'rider', 'createdAt': '2026-10-16T09:00:00Z'},
        {'id': 3, 'role': 'retailer'},
      ],
      readyShops: const [
        {'id': 1},
      ],
      flaggedUsers: null, // that call failed
      productRequests: const [],
    );
    final q = dto.toEntity(refreshedAt: DateTime.utc(2026, 10, 16, 10));
    int? count(AdminQueueType t) =>
        q.queues.firstWhere((x) => x.type == t).count;
    expect(count(AdminQueueType.kyc), 3);
    expect(count(AdminQueueType.shops), 1);
    expect(count(AdminQueueType.users), isNull);
    expect(count(AdminQueueType.productRequests), 0);
    expect(count(AdminQueueType.catalogueVariants), isNull);
    expect(q.totalPending, 4);
    expect(q.unknownCount, 2);
    expect(q.kycRetailers, 2);
    expect(q.kycRiders, 1);
    expect(q.kycOldestAt, DateTime.utc(2026, 10, 15, 8));
  });
}
