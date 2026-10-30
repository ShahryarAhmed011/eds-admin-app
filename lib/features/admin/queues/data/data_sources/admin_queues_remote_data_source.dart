import '../../../../../core/core.dart';
import '../dto/admin_queue_counts_dto.dart';
import 'admin_queues_data_source.dart';

class AdminQueuesRemoteDataSource implements AdminQueuesDataSource {
  const AdminQueuesRemoteDataSource(this._api);

  final ApiClient _api;

  // Status values assumed by the shops/users features (undocumented).
  static const _readyShopStatus = 'kyc_approved';
  static const _flaggedUserStatus = 'flagged';
  static const _limit = 100;

  @override
  Future<AdminQueueCountsDto> fetchCounts() async {
    Object? firstError;
    Future<List<Json>?> tolerant(Future<List<Json>> call) =>
        call.then<List<Json>?>(
          (items) => items,
          onError: (Object e) {
            firstError ??= e;
            return null;
          },
        );

    final results = await Future.wait([
      tolerant(_api.getItems('/admin/kyc')),
      tolerant(
        _api.getItems(
          '/admin/stores',
          query: {'status': _readyShopStatus, 'limit': _limit},
        ),
      ),
      tolerant(
        _api.getItems(
          '/admin/users',
          query: {'status': _flaggedUserStatus, 'limit': _limit},
        ),
      ),
      tolerant(
        _api.getItems(
          '/admin/product-requests',
          query: {'status': 'pending', 'limit': _limit},
        ),
      ),
    ]);
    if (results.every((r) => r == null)) throw firstError!;
    return AdminQueueCountsDto.fromResponses(
      kyc: results[0],
      readyShops: results[1],
      flaggedUsers: results[2],
      productRequests: results[3],
    );
  }
}
