part of 'admin_users_list_bloc.dart';

sealed class AdminUsersListEvent extends Equatable {
  const AdminUsersListEvent();

  @override
  List<Object?> get props => [];
}

final class AdminUsersListRequested extends AdminUsersListEvent {
  const AdminUsersListRequested();
}

final class AdminUsersListTabChanged extends AdminUsersListEvent {
  const AdminUsersListTabChanged(this.tab);

  final UsersListTab tab;

  @override
  List<Object?> get props => [tab];
}

final class AdminUsersListSearchChanged extends AdminUsersListEvent {
  const AdminUsersListSearchChanged(this.query);

  final String query;

  @override
  List<Object?> get props => [query];
}
