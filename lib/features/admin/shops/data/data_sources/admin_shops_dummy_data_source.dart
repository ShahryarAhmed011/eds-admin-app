import '../../../../../core/core.dart';
import '../dto/admin_shop_dto.dart';
import 'admin_shops_data_source.dart';

/// Figma data in the `GET /admin/stores` shape, filtered like the server.
class AdminShopsDummyDataSource implements AdminShopsDataSource {
  static const List<Json> _rows = [
    {
      'id': 'SH-021',
      'name': 'Mehran General Store',
      'slug': 'mehran-general-store',
      'ownerUserId': 'USR-142',
      'categoryCode': 'grocery',
      'status': 'kyc_approved',
      'statusReason': null,
      'productCount': 48,
      'areaId': 113,
      'landmark': 'Street 8 · Islamabad',
      'createdAt': '2026-10-15T10:00:00+05:00',
      'ownerName': 'Muhammad Ali',
      'phone': '+92 301 2345678',
      'areaName': 'G-11/3',
      'kycReviewLabel': '16 Oct 2026 · Review KYC-308',
      'hoursLabel': 'Daily · 08:00 am – 11:00 pm PKT',
      'pinLabel': '33.6694, 72.9982',
      'updatedLabel': 'Last updated by retailer · Today, 9:20 am',
    },
    {
      'id': 'SH-022',
      'name': 'Green Basket Mart',
      'slug': 'green-basket-mart',
      'ownerUserId': 'USR-120',
      'categoryCode': 'grocery',
      'status': 'kyc_approved',
      'statusReason': null,
      'productCount': 72,
      'areaId': 102,
      'landmark': 'Street 14 · Islamabad',
      'createdAt': '2026-10-14T12:00:00+05:00',
      'ownerName': 'Farhan Iqbal',
      'phone': '+92 304 1112223',
      'areaName': 'G-10/2',
      'kycReviewLabel': '15 Oct 2026 · Review KYC-301',
      'hoursLabel': 'Daily · 09:00 am – 10:00 pm PKT',
      'pinLabel': '33.6812, 73.0145',
      'updatedLabel': 'Last updated by retailer · Yesterday, 6:05 pm',
    },
    {
      'id': 'SH-024',
      'name': 'Daily Needs Store',
      'slug': 'daily-needs-store',
      'ownerUserId': 'USR-125',
      'categoryCode': 'grocery',
      'status': 'kyc_approved',
      'statusReason': null,
      'productCount': 31,
      'areaId': 114,
      'landmark': 'Street 3 · Islamabad',
      'createdAt': '2026-10-14T15:00:00+05:00',
      'ownerName': 'Hina Tariq',
      'phone': '+92 322 7778889',
      'areaName': 'G-11/4',
      'kycReviewLabel': '15 Oct 2026 · Review KYC-304',
      'hoursLabel': 'Daily · 08:30 am – 11:30 pm PKT',
      'pinLabel': '33.6651, 72.9890',
      'updatedLabel': 'Last updated by retailer · Today, 8:10 am',
    },
    {
      'id': 'SH-032',
      'name': 'Bilal General Store',
      'slug': 'bilal-general-store',
      'ownerUserId': 'USR-088',
      'categoryCode': 'grocery',
      'status': 'suspended',
      'statusReason': 'Repeated inaccurate stock reports.',
      'productCount': 22,
      'areaId': 301,
      'landmark': 'Commercial Market · Rawalpindi',
      'createdAt': '2026-09-02T10:30:00+05:00',
      'ownerName': 'Bilal Hassan',
      'phone': '+92 302 4567890',
      'areaName': 'Satellite Town',
      'kycReviewLabel': '03 Sep 2026 · Review KYC-214',
      'hoursLabel': 'Daily · 09:00 am – 11:00 pm PKT',
      'pinLabel': '33.6401, 73.0712',
      'updatedLabel': 'Last updated by retailer · 12 Oct, 4:30 pm',
    },
    {
      'id': 'SH-027',
      'name': 'Fresh Corner Mart',
      'slug': 'fresh-corner-mart',
      'ownerUserId': 'USR-097',
      'categoryCode': 'grocery',
      'status': 'flagged',
      'statusReason': 'Two price complaints under review.',
      'productCount': 39,
      'areaId': 104,
      'landmark': 'Street 21 · Islamabad',
      'createdAt': '2026-09-20T11:00:00+05:00',
      'ownerName': 'Asad Mehmood',
      'phone': '+92 315 6667778',
      'areaName': 'G-10/4',
      'kycReviewLabel': '20 Sep 2026 · Review KYC-241',
      'hoursLabel': 'Daily · 10:00 am – 10:00 pm PKT',
      'pinLabel': '33.6789, 73.0201',
      'updatedLabel': 'Last updated by retailer · 14 Oct, 11:45 am',
    },
  ];

  @override
  Future<List<AdminShopDto>> fetchShops({
    String? status,
    int limit = 50,
  }) async {
    await dummyDelay();
    return [
      for (final row in _rows)
        if (status == null || row['status'] == status)
          AdminShopDto.fromJson(row),
    ].take(limit).toList();
  }

  @override
  Future<AdminShopDto> updateStatus({
    required String id,
    required String status,
    required String reason,
  }) async {
    await dummyDelay();
    final row = _rows.firstWhere(
      (r) => r['id'] == id,
      orElse: () => throw const ApiException(
        status: 404,
        code: ApiErrorCode.notFound,
        message: 'Shop not found.',
      ),
    );
    return AdminShopDto.fromJson({
      ...row,
      'status': status,
      'statusReason': reason,
    });
  }
}
