import '../../../../../core/core.dart';
import '../entities/admin_catalogue_variant.dart';
import '../repository/admin_catalogue_repository.dart';

class GetCatalogueVariant implements UseCase<CatalogueVariantDetail, String> {
  const GetCatalogueVariant(this._repository);

  final AdminCatalogueRepository _repository;

  @override
  Future<CatalogueVariantDetail> call(String id) => _repository.getVariant(id);
}
