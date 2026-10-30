part of 'admin_shops_list_bloc.dart';

sealed class AdminShopsListEvent extends Equatable {
  const AdminShopsListEvent();

  @override
  List<Object?> get props => [];
}

final class AdminShopsListRequested extends AdminShopsListEvent {
  const AdminShopsListRequested();
}

final class AdminShopsListTabChanged extends AdminShopsListEvent {
  const AdminShopsListTabChanged(this.tab);

  final ShopsListTab tab;

  @override
  List<Object?> get props => [tab];
}

final class AdminShopsListSearchChanged extends AdminShopsListEvent {
  const AdminShopsListSearchChanged(this.query);

  final String query;

  @override
  List<Object?> get props => [query];
}
