import '../../../../../core/core.dart';
import '../../domain/entities/admin_shop.dart';
import '../../domain/repository/admin_shops_repository.dart';
import '../data_sources/admin_shops_data_source.dart';
import '../dto/admin_shop_dto.dart';
import '../mappers/admin_shop_mapper.dart';

class AdminShopsRepositoryImpl implements AdminShopsRepository {
  AdminShopsRepositoryImpl(this._dataSource);

  final AdminShopsDataSource _dataSource;
  final Map<String, AdminShop> _cache = {};

  @override
  Future<List<AdminShop>> getShops(AdminShopsFilter filter) async {
    final statuses = switch (filter) {
      AdminShopsFilter.all => <String?>[null],
      AdminShopsFilter.ready => [AdminShopApiStatus.ready],
      // The API filters one status at a time.
      AdminShopsFilter.needsAttention => [
        AdminShopApiStatus.flagged,
        AdminShopApiStatus.suspended,
      ],
    };
    final pages = await Future.wait([
      for (final status in statuses)
        _dataSource.fetchShops(
          status: status,
          limit: AdminShopsRepository.pageLimit,
        ),
    ]);
    final shops = [
      for (final page in pages)
        for (final dto in page) dto.toEntity(),
    ];
    for (final s in shops) {
      _cache[s.id] = s;
    }
    return shops;
  }

  @override
  Future<AdminShop> getShop(String id) async {
    final cached = _cache[id];
    if (cached != null) return cached;
    await getShops(AdminShopsFilter.all);
    return _cache[id] ??
        (throw const ApiException(
          status: 404,
          code: ApiErrorCode.notFound,
          message: 'This shop could not be found.',
        ));
  }

  @override
  Future<AdminShop> updateStatus({
    required AdminShop shop,
    required AdminShopStatusAction action,
    required String reason,
  }) async {
    final dto = await _dataSource.updateStatus(
      id: shop.id,
      status: adminShopActionToApi(action),
      reason: reason,
    );
    final updated = dto.toEntity().mergeFrom(shop);
    _cache[shop.id] = updated;
    return updated;
  }
}
