import '../../../../../core/core.dart';
import '../dto/catalogue_variant_dto.dart';
import 'admin_catalogue_data_source.dart';

/// Prefilled data matching the Figma catalogue screens, in the admin variant
/// API shape plus the review/listing fields the API does not provide yet.
class AdminCatalogueDummyDataSource implements AdminCatalogueDataSource {
  static final Map<String, Json> _variants = {
    for (final v in const [
      {
        'id': 'SKU-001',
        'skuCode': 'SKU-001',
        'productName': 'Pure milk',
        'variantLabel': '1 litre',
        'packSize': 1,
        'unitCode': 'litre',
        'marketPricePaisa': 28000,
        'status': 'active',
        'barcode': '8961008001234',
        'categoryName': 'Dairy',
        'description': 'Full cream · 1 litre carton',
        'needsReview': true,
        'reviewSeverity': 'medium',
        'reviewTitle': 'Data-quality review',
        'reviewMessage':
            'Confirm the carton pack description. Price is set separately '
            'by each retailer.',
        'listNote': '18 shop listings',
        'linkedListings': 18,
        'priceMinPaisa': 27000,
        'priceMaxPaisa': 30000,
        'sourceLabel': 'Manual catalogue · 12 Oct',
        'lastEditedLabel': 'Last edited by Nadia · 15 Oct, 3:15 pm',
      },
      {
        'id': 'SKU-014',
        'skuCode': 'SKU-014',
        'productName': 'Basmati rice',
        'variantLabel': '5 kg',
        'packSize': 5,
        'unitCode': 'kg',
        'marketPricePaisa': 185000,
        'status': 'active',
        'barcode': '8964002005501',
        'categoryName': 'Pantry',
        'description': 'Long grain · 5 kg bag',
        'needsReview': true,
        'reviewSeverity': 'medium',
        'reviewTitle': 'Pack-size check',
        'reviewMessage':
            'Two sources list this barcode as 4.5 kg. Confirm the pack size '
            'before keeping it active.',
        'listNote': 'Pack-size check',
        'linkedListings': 9,
        'priceMinPaisa': 178000,
        'priceMaxPaisa': 195000,
        'sourceLabel': 'Scraper SCR-041 · 15 Oct',
        'lastEditedLabel': 'Last edited by Hamza · 15 Oct, 6:20 pm',
      },
      {
        'id': 'SKU-028',
        'skuCode': 'SKU-028',
        'productName': 'White sugar',
        'variantLabel': '1 kg',
        'packSize': 1,
        'unitCode': 'kg',
        'marketPricePaisa': 16500,
        'status': 'active',
        'barcode': '8961100028007',
        'categoryName': 'Pantry',
        'description': 'Refined · 1 kg pack',
        'needsReview': true,
        'reviewSeverity': 'high',
        'reviewTitle': 'Duplicate barcode',
        'reviewMessage':
            'The same barcode is used by SKU-029. Mark one variant as a '
            'duplicate or correct the barcode.',
        'listNote': 'Duplicate barcode',
        'linkedListings': 14,
        'priceMinPaisa': 15500,
        'priceMaxPaisa': 17500,
        'sourceLabel': 'Manual catalogue · 03 Oct',
        'lastEditedLabel': 'Last edited by Nadia · 14 Oct, 11:05 am',
      },
      {
        'id': 'SKU-010',
        'skuCode': 'SKU-010',
        'productName': 'Cooking oil',
        'variantLabel': '1 kg',
        'packSize': 1,
        'unitCode': 'kg',
        'marketPricePaisa': 56000,
        'status': 'active',
        'barcode': '8964000110102',
        'categoryName': 'Pantry',
        'description': 'Canola · 1 kg pouch',
        'listNote': '22 shop listings',
        'linkedListings': 22,
        'priceMinPaisa': 54000,
        'priceMaxPaisa': 59000,
        'sourceLabel': 'Manual catalogue · 20 Sep',
        'lastEditedLabel': 'Last edited by Nadia · 16 Oct, 9:10 am',
      },
      {
        'id': 'SKU-035',
        'skuCode': 'SKU-035',
        'productName': 'Green tea',
        'variantLabel': '25 bags',
        'packSize': 25,
        'unitCode': 'pack',
        'marketPricePaisa': 32000,
        'status': 'inactive',
        'barcode': '8961200035354',
        'categoryName': 'Beverages',
        'description': 'Jasmine · 25 tea bags',
        'listNote': 'No active listings',
        'linkedListings': 0,
        'priceMinPaisa': 30000,
        'priceMaxPaisa': 34000,
        'sourceLabel': 'Manual catalogue · 01 Sep',
        'lastEditedLabel': 'Last edited by Hamza · 10 Oct, 2:40 pm',
      },
    ])
      v['id']! as String: Map<String, dynamic>.of(v),
  };

  @override
  Future<CatalogueVariantsPageDto> fetchVariants() async {
    await dummyDelay();
    return CatalogueVariantsPageDto.fromJson({
      'total': 1248,
      'reviewCount': 4,
      'inactiveCount': 18,
      'items': _variants.values.toList(),
    });
  }

  @override
  Future<CatalogueVariantDto> fetchVariant(String id) async {
    await dummyDelay();
    return CatalogueVariantDto.fromJson(_find(id));
  }

  @override
  Future<void> submitVariantAction({
    required String id,
    required String action,
    required String reason,
  }) async {
    await dummyDelay();
    _find(id);
  }

  @override
  Future<CatalogueVariantDto> updateMarketPrice({
    required String id,
    required int marketPricePaisa,
  }) async {
    await dummyDelay();
    final variant = _find(id)..['marketPricePaisa'] = marketPricePaisa;
    return CatalogueVariantDto.fromJson(variant);
  }

  Json _find(String id) {
    final variant = _variants[id];
    if (variant == null) {
      throw const ApiException(
        status: 404,
        code: ApiErrorCode.notFound,
        message: 'Variant not found.',
      );
    }
    return variant;
  }
}
