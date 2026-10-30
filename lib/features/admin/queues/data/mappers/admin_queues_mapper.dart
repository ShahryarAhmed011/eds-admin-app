import '../../domain/entities/admin_queues.dart';
import '../dto/admin_queue_counts_dto.dart';

extension AdminQueueCountsDtoMapper on AdminQueueCountsDto {
  AdminQueues toEntity({required DateTime refreshedAt}) {
    final kyc = kycItems;
    DateTime? oldest;
    for (final item in kyc ?? const <KycQueueItemDto>[]) {
      final at = item.createdAt;
      if (at != null && (oldest == null || at.isBefore(oldest))) oldest = at;
    }
    int? countRole(String role) =>
        kyc?.where((i) => i.role.toLowerCase() == role).length;
    return AdminQueues(
      region: region,
      refreshedAt: refreshedAt,
      kycRetailers: countRole('retailer'),
      kycRiders: countRole('rider'),
      kycOldestAt: oldest,
      queues: [
        AdminQueue(type: AdminQueueType.kyc, count: kyc?.length),
        AdminQueue(type: AdminQueueType.shops, count: readyShopItems),
        AdminQueue(type: AdminQueueType.users, count: flaggedUserItems),
        AdminQueue(
          type: AdminQueueType.productRequests,
          count: productRequestItems,
        ),
        AdminQueue(
          type: AdminQueueType.catalogueVariants,
          count: catalogueVariantCount,
        ),
      ],
    );
  }
}
