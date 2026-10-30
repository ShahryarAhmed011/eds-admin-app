import '../dto/catalogue_variant_dto.dart';

abstract interface class AdminCatalogueDataSource {
  Future<CatalogueVariantsPageDto> fetchVariants();

  Future<CatalogueVariantDto> fetchVariant(String id);

  Future<void> submitVariantAction({
    required String id,
    required String action,
    required String reason,
  });

  Future<CatalogueVariantDto> updateMarketPrice({
    required String id,
    required int marketPricePaisa,
  });
}
