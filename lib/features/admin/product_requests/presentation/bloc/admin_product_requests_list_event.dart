part of 'admin_product_requests_list_bloc.dart';

sealed class AdminProductRequestsListEvent extends Equatable {
  const AdminProductRequestsListEvent();

  @override
  List<Object?> get props => [];
}

final class AdminProductRequestsListRequested
    extends AdminProductRequestsListEvent {
  const AdminProductRequestsListRequested();
}

final class AdminProductRequestsListTabChanged
    extends AdminProductRequestsListEvent {
  const AdminProductRequestsListTabChanged(this.tab);

  final ProductRequestStatus tab;

  @override
  List<Object?> get props => [tab];
}

final class AdminProductRequestsListSearchChanged
    extends AdminProductRequestsListEvent {
  const AdminProductRequestsListSearchChanged(this.query);

  final String query;

  @override
  List<Object?> get props => [query];
}
