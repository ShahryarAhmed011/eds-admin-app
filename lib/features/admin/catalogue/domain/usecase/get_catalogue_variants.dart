import '../../../../../core/core.dart';
import '../entities/admin_catalogue_variant.dart';
import '../repository/admin_catalogue_repository.dart';

class GetCatalogueVariants implements UseCase<CatalogueVariantsPage, NoParams> {
  const GetCatalogueVariants(this._repository);

  final AdminCatalogueRepository _repository;

  @override
  Future<CatalogueVariantsPage> call(NoParams params) =>
      _repository.getVariants();
}
