import '../../../../../core/core.dart';
import '../../domain/entities/admin_catalogue_variant.dart';
import '../../domain/repository/admin_catalogue_repository.dart';
import '../data_sources/admin_catalogue_data_source.dart';
import '../mappers/catalogue_variant_mapper.dart';

class AdminCatalogueRepositoryImpl implements AdminCatalogueRepository {
  const AdminCatalogueRepositoryImpl(this._dataSource);

  final AdminCatalogueDataSource _dataSource;

  @override
  Future<CatalogueVariantsPage> getVariants() async =>
      (await _dataSource.fetchVariants()).toEntity();

  @override
  Future<CatalogueVariantDetail> getVariant(String id) async =>
      (await _dataSource.fetchVariant(id)).toDetail();

  @override
  Future<void> submitVariantAction({
    required String id,
    required CatalogueVariantAction action,
    required String reason,
  }) => _dataSource.submitVariantAction(
    id: id,
    action: switch (action) {
      CatalogueVariantAction.approve => 'approve',
      CatalogueVariantAction.deactivate => 'deactivate',
      CatalogueVariantAction.markDuplicate => 'mark_duplicate',
    },
    reason: reason,
  );

  @override
  Future<CatalogueVariantSummary> updateMarketPrice({
    required String id,
    required Money price,
  }) async => (await _dataSource.updateMarketPrice(
    id: id,
    marketPricePaisa: price.paisa,
  )).toSummary();
}
