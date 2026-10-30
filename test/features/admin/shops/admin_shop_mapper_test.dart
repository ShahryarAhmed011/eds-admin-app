import 'package:eds_admin_app/features/admin/shops/data/data_sources/admin_shops_data_source.dart';
import 'package:eds_admin_app/features/admin/shops/data/dto/admin_shop_dto.dart';
import 'package:eds_admin_app/features/admin/shops/data/mappers/admin_shop_mapper.dart';
import 'package:eds_admin_app/features/admin/shops/data/repository/admin_shops_repository_impl.dart';
import 'package:eds_admin_app/features/admin/shops/domain/entities/admin_shop.dart';
import 'package:eds_admin_app/features/admin/shops/domain/repository/admin_shops_repository.dart';
import 'package:flutter_test/flutter_test.dart';

// GET /admin/shops item, field names from docs/api/curl-reference.md.
const _row = {
  'id': 21,
  'name': 'Mehran General Store',
  'slug': 'mehran-general-store',
  'ownerUserId': 142,
  'categoryCode': 'grocery',
  'status': 'kyc_approved',
  'statusReason': null,
  'productCount': 48,
  'areaId': 113,
  'landmark': 'Street 8',
  'createdAt': '2026-10-15T05:00:00Z',
};

class _FakeSource implements AdminShopsDataSource {
  final requested = <String?>[];

  @override
  Future<List<AdminShopDto>> fetchShops({
    String? status,
    int limit = 50,
  }) async {
    requested.add(status);
    return [
      AdminShopDto.fromJson({..._row, 'status': status ?? 'live'}),
    ];
  }

  @override
  Future<AdminShopDto> updateStatus({
    required String id,
    required String status,
    required String reason,
  }) async => AdminShopDto.fromJson({..._row, 'status': status});
}

void main() {
  test('maps an API shop', () {
    final s = AdminShopDto.fromJson(_row).toEntity();
    expect(s.id, '21');
    expect(s.reference, 'SH-21');
    expect(s.ownerUserId, '142');
    expect(s.status, AdminShopStatus.approved);
    expect(s.productCount, 48);
    expect(s.areaId, '113');
    expect(s.statusReason, isNull);
    expect(s.hoursLabel, isNull);
  });

  test('unknown status keeps the raw value', () {
    final s = AdminShopDto.fromJson({..._row, 'status': 'archived'}).toEntity();
    expect(s.status, AdminShopStatus.unknown);
    expect(s.rawStatus, 'archived');
  });

  test('needs-attention filter queries flagged and suspended', () async {
    final source = _FakeSource();
    final shops = await AdminShopsRepositoryImpl(
      source,
    ).getShops(AdminShopsFilter.needsAttention);
    expect(source.requested, ['flagged', 'suspended']);
    expect(shops, hasLength(2));
  });

  test('set live sends "live" and keeps the record', () async {
    final repo = AdminShopsRepositoryImpl(_FakeSource());
    final shop = await repo.getShop('21');
    final updated = await repo.updateStatus(
      shop: shop,
      action: AdminShopStatusAction.setLive,
      reason: 'Ready.',
    );
    expect(updated.status, AdminShopStatus.live);
    expect(updated.name, 'Mehran General Store');
  });
}
