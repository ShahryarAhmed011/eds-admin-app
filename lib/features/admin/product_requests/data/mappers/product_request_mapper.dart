import '../../../../../core/core.dart';
import '../../domain/entities/admin_product_request.dart';
import '../dto/product_request_dto.dart';

ProductRequestStatus parseRequestStatus(String? status) =>
    switch (status?.toLowerCase()) {
      'approved' || 'resolved' => ProductRequestStatus.approved,
      'rejected' => ProductRequestStatus.rejected,
      _ => ProductRequestStatus.pending,
    };

extension ProductRequestDtoMapper on ProductRequestDto {
  ProductRequestSummary toSummary() => ProductRequestSummary(
    id: id,
    code: code ?? 'REQ-$id',
    productName: productName,
    packLabel: packSizeText ?? '',
    shopId: shopId,
    status: parseRequestStatus(status),
    shopName: shopName,
  );

  ProductRequestDetail toDetail() => ProductRequestDetail(
    summary: toSummary(),
    brand: brandName,
    description: description,
    submittedAt: createdAt,
    category: categoryName,
    categoryId: categoryId,
    barcode: barcode,
    packDetail: packSizeText,
    shopOwner: shopOwner,
    shopPhone: shopPhone,
    duplicateCheck: duplicateCheck == null
        ? null
        : ProductRequestDuplicateCheck(
            isDuplicate: duplicateCheck!.isDuplicate,
            title: duplicateCheck!.title,
            message: duplicateCheck!.message,
          ),
    suggestedPrice: suggestedPricePaisa == null
        ? null
        : Money(suggestedPricePaisa!),
    retailerNote: retailerNote,
    rejectionReason: rejectionReason,
  );
}

extension ProductRequestsPageDtoMapper on ProductRequestsPageDto {
  ProductRequestsPage toEntity() => ProductRequestsPage(
    totalCount: total,
    items: [for (final item in items) item.toSummary()],
  );
}

/// Body for `POST /admin/catalog/variants` built from a request, or null
/// when the pack size text cannot be read as `<number> <unit>`.
Json? createVariantBody(ProductRequestDetail request) {
  final match = RegExp(
    r'^\s*([\d.,]+)\s*([a-zA-Z]+)',
  ).firstMatch(request.packDetail ?? request.summary.packLabel);
  final size = double.tryParse(match?.group(1)?.replaceAll(',', '') ?? '');
  if (match == null || size == null) return null;
  return {
    'name': request.summary.productName,
    'brand': ?request.brand,
    'category': ?(request.category ?? request.categoryId),
    'packSize': size,
    'unitCode': match.group(2)!.toLowerCase(),
    'pricePaisa': ?request.suggestedPrice?.paisa,
    'barcode': ?request.barcode,
  };
}
