import '../../../../../core/core.dart';
import '../dto/product_request_dto.dart';
import 'admin_product_requests_data_source.dart';

/// Prefilled data matching the Figma product request screens, in the admin
/// API shape plus shop/category/duplicate fields the API lacks.
class AdminProductRequestsDummyDataSource
    implements AdminProductRequestsDataSource {
  /// Pending total shown in Figma ("Showing 3 of 7").
  static const _pendingTotal = 7;

  final Map<String, Json> _requests = {
    for (final r in const [
      {
        'id': 'REQ-104',
        'code': 'REQ-104',
        'shopId': 'SH-031',
        'shopName': 'Mehran General Store',
        'shopOwner': 'Muhammad Ali',
        'shopPhone': '+92 301 2345678',
        'productName': 'Rooh Afza',
        'brandName': 'Hamdard',
        'description': 'Rose syrup',
        'packSizeText': '800 ml',
        'categoryId': 7,
        'categoryName': 'Beverages',
        'barcode': '8964001234567',
        'status': 'pending',
        'createdAt': '2026-10-16T09:10:00+05:00',
        'retailerNote': 'Stock available in our shop.',
        'duplicateCheck': {
          'isDuplicate': false,
          'title': 'No exact duplicate found',
          'message':
              'Nearest variant: Rooh Afza 1,500 ml. This request has a '
              'different pack size.',
        },
      },
      {
        'id': 'REQ-103',
        'code': 'REQ-103',
        'shopId': 'SH-027',
        'shopName': 'Green Basket Mart',
        'shopOwner': 'Sana Iqbal',
        'shopPhone': '+92 333 7654321',
        'productName': 'Tapal Danedar',
        'brandName': 'Tapal',
        'description': 'Black tea',
        'packSizeText': '430 g',
        'categoryId': 7,
        'categoryName': 'Beverages',
        'barcode': '8964000123459',
        'suggestedPricePaisa': 115000,
        'status': 'pending',
        'createdAt': '2026-10-16T08:42:00+05:00',
        'duplicateCheck': {
          'isDuplicate': false,
          'title': 'No exact duplicate found',
          'message':
              'Nearest variant: Tapal Danedar 900 g. This request has a '
              'different pack size.',
        },
      },
      {
        'id': 'REQ-102',
        'code': 'REQ-102',
        'shopId': 'SH-019',
        'shopName': 'Daily Needs Store',
        'shopOwner': 'Ahmed Raza',
        'shopPhone': '+92 300 1122334',
        'productName': 'National salt',
        'brandName': 'National',
        'description': 'Iodized salt',
        'packSizeText': '1 kg',
        'categoryId': 3,
        'categoryName': 'Pantry',
        'barcode': '8961008100026',
        'status': 'pending',
        'createdAt': '2026-10-15T19:30:00+05:00',
        'retailerNote': 'Customers ask for this brand.',
        'duplicateCheck': {
          'isDuplicate': true,
          'title': 'Possible duplicate',
          'message': 'SKU-044 National salt 1 kg uses the same barcode.',
        },
      },
      {
        'id': 'REQ-098',
        'code': 'REQ-098',
        'shopId': 'SH-025',
        'shopName': 'City Essentials',
        'shopOwner': 'Usman Tariq',
        'shopPhone': '+92 321 5566778',
        'productName': 'Shan biryani masala',
        'brandName': 'Shan',
        'description': 'Spice mix',
        'packSizeText': '50 g',
        'categoryId': 3,
        'categoryName': 'Pantry',
        'barcode': '8964000510051',
        'suggestedPricePaisa': 14000,
        'status': 'approved',
        'resolvedVariantId': 'SKU-212',
        'createdAt': '2026-10-14T13:05:00+05:00',
      },
      {
        'id': 'REQ-095',
        'code': 'REQ-095',
        'shopId': 'SH-027',
        'shopName': 'Green Basket Mart',
        'shopOwner': 'Sana Iqbal',
        'shopPhone': '+92 333 7654321',
        'productName': 'Olpers milk',
        'brandName': 'Olpers',
        'description': 'UHT milk',
        'packSizeText': '1 litre',
        'categoryId': 1,
        'categoryName': 'Dairy',
        'barcode': '8961008002217',
        'status': 'rejected',
        'rejectionReason': 'Duplicate of SKU-002.',
        'createdAt': '2026-10-13T11:20:00+05:00',
      },
    ])
      r['id']! as String: Map<String, dynamic>.of(r),
  };

  @override
  Future<ProductRequestsPageDto> fetchRequests(String status) async {
    await dummyDelay();
    final items = [
      for (final r in _requests.values)
        if (r['status'] == status) r,
    ];
    return ProductRequestsPageDto.fromJson({
      'items': items,
      if (status == 'pending')
        'total': _pendingTotal - (3 - items.length).clamp(0, 3),
    }, status: status);
  }

  @override
  Future<ProductRequestDto> fetchRequest(String id) async {
    await dummyDelay();
    return ProductRequestDto.fromJson(_find(id));
  }

  @override
  Future<String> createVariant(Json body) async {
    await dummyDelay();
    return 'SKU-213';
  }

  @override
  Future<ProductRequestDto> approve(
    String id, {
    String? resolvedVariantId,
    required bool duplicate,
  }) async {
    await dummyDelay();
    final request = _find(id)
      ..['status'] = 'approved'
      ..['resolvedVariantId'] = resolvedVariantId;
    return ProductRequestDto.fromJson(request);
  }

  @override
  Future<ProductRequestDto> reject(String id, {required String reason}) async {
    await dummyDelay();
    final request = _find(id)
      ..['status'] = 'rejected'
      ..['rejectionReason'] = reason;
    return ProductRequestDto.fromJson(request);
  }

  Json _find(String id) {
    final request = _requests[id];
    if (request == null) {
      throw const ApiException(
        status: 404,
        code: ApiErrorCode.notFound,
        message: 'This product request could not be found.',
      );
    }
    return request;
  }
}
