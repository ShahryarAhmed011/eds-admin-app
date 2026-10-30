import '../../../../../core/core.dart';

/// Product request in the shape of `GET /admin/product-requests` items and
/// the approve/reject responses. Shop, category name, note and duplicate
/// check are not in the API yet and are only filled by the dummy source.
class ProductRequestDto {
  const ProductRequestDto({
    required this.id,
    required this.shopId,
    required this.productName,
    this.code,
    this.brandName,
    this.packSizeText,
    this.categoryId,
    this.categoryName,
    this.barcode,
    this.suggestedPricePaisa,
    this.status,
    this.rejectionReason,
    this.resolvedVariantId,
    this.createdAt,
    this.description,
    this.shopName,
    this.shopOwner,
    this.shopPhone,
    this.retailerNote,
    this.duplicateCheck,
  });

  factory ProductRequestDto.fromJson(Json json) => ProductRequestDto(
    id: json.id(),
    code: json.str('code'),
    shopId: json.id('shopId'),
    productName: json.strOr('productName'),
    brandName: json.str('brandName'),
    packSizeText: json.str('packSizeText'),
    categoryId: json.str('categoryId'),
    categoryName: json.str('categoryName'),
    barcode: json.str('barcode'),
    suggestedPricePaisa: json.integer('suggestedPricePaisa'),
    status: json.str('status'),
    rejectionReason: json.str('rejectionReason'),
    resolvedVariantId: json.str('resolvedVariantId'),
    createdAt: json.date('createdAt'),
    description: json.str('description'),
    shopName: json.str('shopName'),
    shopOwner: json.str('shopOwner'),
    shopPhone: json.str('shopPhone'),
    retailerNote: json.str('retailerNote'),
    duplicateCheck: json.obj('duplicateCheck') == null
        ? null
        : DuplicateCheckDto.fromJson(json.obj('duplicateCheck')!),
  );

  final String id;
  final String? code;
  final String shopId;
  final String productName;
  final String? brandName;
  final String? packSizeText;
  final String? categoryId;
  final String? categoryName;
  final String? barcode;
  final int? suggestedPricePaisa;
  final String? status;
  final String? rejectionReason;
  final String? resolvedVariantId;
  final DateTime? createdAt;
  final String? description;
  final String? shopName;
  final String? shopOwner;
  final String? shopPhone;
  final String? retailerNote;
  final DuplicateCheckDto? duplicateCheck;
}

class DuplicateCheckDto {
  const DuplicateCheckDto({
    required this.isDuplicate,
    required this.title,
    this.message,
  });

  factory DuplicateCheckDto.fromJson(Json json) => DuplicateCheckDto(
    isDuplicate: json.boolean('isDuplicate'),
    title: json.strOr('title'),
    message: json.str('message'),
  );

  final bool isDuplicate;
  final String title;
  final String? message;
}

class ProductRequestsPageDto {
  const ProductRequestsPageDto({required this.items, this.total});

  /// [status] fills in items that omit their own status.
  factory ProductRequestsPageDto.fromJson(Json json, {String? status}) =>
      ProductRequestsPageDto(
        total: json.integer('total'),
        items: [
          for (final item in json.objList('items'))
            ProductRequestDto.fromJson({'status': ?status, ...item}),
        ],
      );

  final List<ProductRequestDto> items;
  final int? total;
}
