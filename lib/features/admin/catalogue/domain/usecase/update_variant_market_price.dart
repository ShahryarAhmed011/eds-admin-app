import 'package:equatable/equatable.dart';

import '../../../../../core/core.dart';
import '../entities/admin_catalogue_variant.dart';
import '../repository/admin_catalogue_repository.dart';

class UpdateVariantMarketPrice
    implements UseCase<CatalogueVariantSummary, VariantMarketPriceParams> {
  const UpdateVariantMarketPrice(this._repository);

  final AdminCatalogueRepository _repository;

  @override
  Future<CatalogueVariantSummary> call(VariantMarketPriceParams params) =>
      _repository.updateMarketPrice(id: params.id, price: params.price);
}

class VariantMarketPriceParams extends Equatable {
  const VariantMarketPriceParams({required this.id, required this.price});

  final String id;
  final Money price;

  @override
  List<Object?> get props => [id, price];
}
