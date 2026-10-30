import '../../../../../core/core.dart';

/// Variant in the shape of `PATCH /admin/catalog/variants/{id}`
/// (`id, sku_code, product_name, variant_label, market_price_paisa,
/// pack_size, unit_code, status`). The review/listing fields have no API yet
/// and are only filled by the dummy source.
class CatalogueVariantDto {
  const CatalogueVariantDto({
    required this.id,
    this.skuCode,
    this.productName,
    this.variantLabel,
    this.packSize,
    this.unitCode,
    this.marketPricePaisa,
    this.status,
    this.barcode,
    this.categoryName,
    this.description,
    this.needsReview = false,
    this.reviewSeverity,
    this.reviewTitle,
    this.reviewMessage,
    this.listNote,
    this.linkedListings,
    this.priceMinPaisa,
    this.priceMaxPaisa,
    this.sourceLabel,
    this.lastEditedLabel,
  });

  factory CatalogueVariantDto.fromJson(Json json) => CatalogueVariantDto(
    id: json.id(),
    skuCode: json.str('skuCode'),
    productName: json.str('productName'),
    variantLabel: json.str('variantLabel'),
    packSize: json.decimal('packSize'),
    unitCode: json.str('unitCode') ?? json.str('unit'),
    marketPricePaisa: json.integer('marketPricePaisa'),
    status: json.str('status'),
    barcode: json.str('barcode'),
    categoryName: json.str('categoryName'),
    description: json.str('description'),
    needsReview: json.boolean('needsReview'),
    reviewSeverity: json.str('reviewSeverity'),
    reviewTitle: json.str('reviewTitle'),
    reviewMessage: json.str('reviewMessage'),
    listNote: json.str('listNote'),
    linkedListings: json.integer('linkedListings'),
    priceMinPaisa: json.integer('priceMinPaisa'),
    priceMaxPaisa: json.integer('priceMaxPaisa'),
    sourceLabel: json.str('sourceLabel'),
    lastEditedLabel: json.str('lastEditedLabel'),
  );

  final String id;
  final String? skuCode;
  final String? productName;
  final String? variantLabel;
  final double? packSize;
  final String? unitCode;
  final int? marketPricePaisa;
  final String? status;
  final String? barcode;
  final String? categoryName;
  final String? description;
  final bool needsReview;
  final String? reviewSeverity;
  final String? reviewTitle;
  final String? reviewMessage;
  final String? listNote;
  final int? linkedListings;
  final int? priceMinPaisa;
  final int? priceMaxPaisa;
  final String? sourceLabel;
  final String? lastEditedLabel;
}

class CatalogueVariantsPageDto {
  const CatalogueVariantsPageDto({
    required this.items,
    this.totalCount,
    this.reviewCount,
    this.inactiveCount,
  });

  factory CatalogueVariantsPageDto.fromJson(Json json) =>
      CatalogueVariantsPageDto(
        totalCount: json.integer('total'),
        reviewCount: json.integer('reviewCount'),
        inactiveCount: json.integer('inactiveCount'),
        items: [
          for (final item in json.objList('items'))
            CatalogueVariantDto.fromJson(item),
        ],
      );

  final int? totalCount;
  final int? reviewCount;
  final int? inactiveCount;
  final List<CatalogueVariantDto> items;
}
