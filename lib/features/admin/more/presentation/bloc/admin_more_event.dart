part of 'admin_more_bloc.dart';

sealed class AdminMoreEvent extends Equatable {
  const AdminMoreEvent();

  @override
  List<Object?> get props => [];
}

final class AdminMoreRequested extends AdminMoreEvent {
  const AdminMoreRequested();
}

final class AdminMoreSignOutRequested extends AdminMoreEvent {
  const AdminMoreSignOutRequested();
}
