import 'package:eds_admin_app/core/core.dart';
import 'package:eds_admin_app/features/admin/catalogue/data/dto/catalogue_variant_dto.dart';
import 'package:eds_admin_app/features/admin/catalogue/data/mappers/catalogue_variant_mapper.dart';
import 'package:eds_admin_app/features/admin/catalogue/domain/entities/admin_catalogue_variant.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('maps the PATCH /admin/catalog/variants response', () {
    final variant = CatalogueVariantDto.fromJson({
      'id': 42,
      'skuCode': 'SKU-042',
      'productName': 'Pure milk',
      'variantLabel': '1 litre',
      'marketPricePaisa': 26000,
      'packSize': 1.0,
      'unitCode': 'l',
      'status': 'active',
    }).toDetail();

    expect(variant.summary.id, '42');
    expect(variant.summary.skuCode, 'SKU-042');
    expect(variant.summary.displayName, 'Pure milk · 1 litre');
    expect(variant.summary.status, CatalogueVariantStatus.active);
    expect(variant.marketPrice, const Money(26000));
    expect(variant.marketPrice!.format(), 'Rs 260');
    expect(variant.reviewTitle, isNull);
  });

  test('builds a pack label when variant_label is missing', () {
    final summary = CatalogueVariantDto.fromJson({
      'id': 7,
      'productName': 'Rice',
      'packSize': 5,
      'unitCode': 'kg',
      'status': 'inactive',
    }).toSummary();

    expect(summary.packLabel, '5 kg');
    expect(summary.skuCode, 'Variant 7');
    expect(summary.status, CatalogueVariantStatus.inactive);
  });
}
