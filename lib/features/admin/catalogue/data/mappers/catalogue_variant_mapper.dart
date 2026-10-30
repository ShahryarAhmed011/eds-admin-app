import '../../../../../core/core.dart';
import '../../domain/entities/admin_catalogue_variant.dart';
import '../dto/catalogue_variant_dto.dart';

String _trimNumber(double value) => value == value.roundToDouble()
    ? value.toInt().toString()
    : value.toString();

extension CatalogueVariantDtoMapper on CatalogueVariantDto {
  CatalogueVariantSummary toSummary() => CatalogueVariantSummary(
    id: id,
    skuCode: skuCode ?? 'Variant $id',
    name: productName ?? 'Unnamed product',
    packLabel:
        variantLabel ??
        [if (packSize != null) _trimNumber(packSize!), ?unitCode].join(' '),
    status: switch (status?.toLowerCase()) {
      'inactive' || 'archived' || 'disabled' => CatalogueVariantStatus.inactive,
      'duplicate' || 'merged' => CatalogueVariantStatus.duplicate,
      _ => CatalogueVariantStatus.active,
    },
    category: categoryName,
    listNote: listNote,
    needsReview: needsReview,
    severity: reviewSeverity == 'high'
        ? CatalogueReviewSeverity.high
        : CatalogueReviewSeverity.medium,
  );

  CatalogueVariantDetail toDetail() => CatalogueVariantDetail(
    summary: toSummary(),
    description: description,
    marketPrice: marketPricePaisa == null ? null : Money(marketPricePaisa!),
    barcode: barcode,
    unit: unitCode,
    sourceLabel: sourceLabel,
    linkedListings: linkedListings,
    priceMin: priceMinPaisa == null ? null : Money(priceMinPaisa!),
    priceMax: priceMaxPaisa == null ? null : Money(priceMaxPaisa!),
    lastEditedLabel: lastEditedLabel,
    reviewTitle: reviewTitle,
    reviewMessage: reviewMessage,
  );
}

extension CatalogueVariantsPageDtoMapper on CatalogueVariantsPageDto {
  CatalogueVariantsPage toEntity() {
    final summaries = [for (final item in items) item.toSummary()];
    return CatalogueVariantsPage(
      totalCount: totalCount ?? summaries.length,
      reviewCount: reviewCount ?? summaries.where((v) => v.needsReview).length,
      inactiveCount:
          inactiveCount ??
          summaries
              .where((v) => v.status != CatalogueVariantStatus.active)
              .length,
      items: summaries,
    );
  }
}
