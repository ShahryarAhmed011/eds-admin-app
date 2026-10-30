import 'package:equatable/equatable.dart';

enum AdminQueueType { kyc, shops, users, productRequests, catalogueVariants }

class AdminQueue extends Equatable {
  const AdminQueue({required this.type, this.count});

  final AdminQueueType type;

  /// Null when the count could not be loaded (or has no endpoint).
  final int? count;

  @override
  List<Object?> get props => [type, count];
}

class AdminQueues extends Equatable {
  const AdminQueues({
    required this.refreshedAt,
    required this.queues,
    this.region,
    this.kycRetailers,
    this.kycRiders,
    this.kycOldestAt,
  });

  /// "Islamabad operations"; not in the API, null from remote.
  final String? region;
  final DateTime refreshedAt;
  final List<AdminQueue> queues;
  final int? kycRetailers;
  final int? kycRiders;
  final DateTime? kycOldestAt;

  int get totalPending => queues.fold(0, (sum, q) => sum + (q.count ?? 0));

  /// Queues whose count is unknown.
  int get unknownCount => queues.where((q) => q.count == null).length;

  @override
  List<Object?> get props => [
    region,
    refreshedAt,
    queues,
    kycRetailers,
    kycRiders,
    kycOldestAt,
  ];
}
