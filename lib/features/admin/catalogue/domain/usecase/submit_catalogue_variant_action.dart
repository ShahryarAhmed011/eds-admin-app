import 'package:equatable/equatable.dart';

import '../../../../../core/core.dart';
import '../entities/admin_catalogue_variant.dart';
import '../repository/admin_catalogue_repository.dart';

class SubmitCatalogueVariantAction
    implements UseCase<void, CatalogueVariantActionParams> {
  const SubmitCatalogueVariantAction(this._repository);

  final AdminCatalogueRepository _repository;

  @override
  Future<void> call(CatalogueVariantActionParams params) =>
      _repository.submitVariantAction(
        id: params.id,
        action: params.action,
        reason: params.reason,
      );
}

class CatalogueVariantActionParams extends Equatable {
  const CatalogueVariantActionParams({
    required this.id,
    required this.action,
    required this.reason,
  });

  final String id;
  final CatalogueVariantAction action;
  final String reason;

  @override
  List<Object?> get props => [id, action, reason];
}
