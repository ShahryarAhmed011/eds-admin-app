import 'package:eds_admin_app/core/core.dart';
import 'package:eds_admin_app/features/admin/product_requests/data/dto/product_request_dto.dart';
import 'package:eds_admin_app/features/admin/product_requests/data/mappers/product_request_mapper.dart';
import 'package:eds_admin_app/features/admin/product_requests/domain/entities/admin_product_request.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const apiPage = {
    'items': [
      {
        'id': 104,
        'shopId': 31,
        'productName': 'Rooh Afza',
        'brandName': 'Hamdard',
        'packSizeText': '800 ml',
        'categoryId': 7,
        'barcode': '8964001234567',
        'suggestedPricePaisa': null,
      },
    ],
  };

  test('maps GET /admin/product-requests items with the queried status', () {
    final page = ProductRequestsPageDto.fromJson(
      apiPage,
      status: 'pending',
    ).toEntity();

    expect(page.count, 1);
    final request = page.items.single;
    expect(request.id, '104');
    expect(request.code, 'REQ-104');
    expect(request.status, ProductRequestStatus.pending);
    expect(request.displayName, 'Rooh Afza · 800 ml');
    expect(request.shopLabel, 'Shop #31');
  });

  test('detail degrades when shop/category/duplicate data is missing', () {
    final detail = ProductRequestDto.fromJson(
      apiPage['items']!.single,
    ).toDetail();

    expect(detail.suggestedPrice, isNull);
    expect(detail.category, isNull);
    expect(detail.categoryId, '7');
    expect(detail.duplicateCheck, isNull);
  });

  test('approve response status and create-variant body', () {
    final approved = ProductRequestDto.fromJson({
      'id': 104,
      'shopId': 31,
      'productName': 'Rooh Afza',
      'packSizeText': '800 ml',
      'suggestedPricePaisa': 45000,
      'status': 'approved',
      'resolvedVariantId': 900,
    }).toDetail();

    expect(approved.summary.status, ProductRequestStatus.approved);
    expect(approved.suggestedPrice, const Money(45000));
    expect(createVariantBody(approved), {
      'name': 'Rooh Afza',
      'packSize': 800.0,
      'unitCode': 'ml',
      'pricePaisa': 45000,
    });
  });
}
