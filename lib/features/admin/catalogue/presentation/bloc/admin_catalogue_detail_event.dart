part of 'admin_catalogue_detail_bloc.dart';

sealed class AdminCatalogueDetailEvent extends Equatable {
  const AdminCatalogueDetailEvent();

  @override
  List<Object?> get props => [];
}

final class AdminCatalogueDetailRequested extends AdminCatalogueDetailEvent {
  const AdminCatalogueDetailRequested(this.id);

  final String id;

  @override
  List<Object?> get props => [id];
}

final class AdminCatalogueVariantActionSubmitted
    extends AdminCatalogueDetailEvent {
  const AdminCatalogueVariantActionSubmitted({
    required this.action,
    required this.reason,
  });

  final CatalogueVariantAction action;
  final String reason;

  @override
  List<Object?> get props => [action, reason];
}
