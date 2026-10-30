part of 'admin_catalogue_list_bloc.dart';

sealed class AdminCatalogueListEvent extends Equatable {
  const AdminCatalogueListEvent();

  @override
  List<Object?> get props => [];
}

final class AdminCatalogueListRequested extends AdminCatalogueListEvent {
  const AdminCatalogueListRequested();
}

final class AdminCatalogueListTabChanged extends AdminCatalogueListEvent {
  const AdminCatalogueListTabChanged(this.tab);

  final CatalogueListTab tab;

  @override
  List<Object?> get props => [tab];
}

final class AdminCatalogueListSearchChanged extends AdminCatalogueListEvent {
  const AdminCatalogueListSearchChanged(this.query);

  final String query;

  @override
  List<Object?> get props => [query];
}
