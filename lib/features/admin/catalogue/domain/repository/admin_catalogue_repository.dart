import '../../../../../core/core.dart';
import '../entities/admin_catalogue_variant.dart';

abstract interface class AdminCatalogueRepository {
  Future<CatalogueVariantsPage> getVariants();

  Future<CatalogueVariantDetail> getVariant(String id);

  Future<void> submitVariantAction({
    required String id,
    required CatalogueVariantAction action,
    required String reason,
  });

  /// Sets the variant's market reference price; returns the saved variant.
  Future<CatalogueVariantSummary> updateMarketPrice({
    required String id,
    required Money price,
  });
}
