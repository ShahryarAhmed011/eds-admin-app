part of 'admin_more_bloc.dart';

sealed class AdminMoreState extends Equatable {
  const AdminMoreState();

  @override
  List<Object?> get props => [];
}

final class AdminMoreLoading extends AdminMoreState {
  const AdminMoreLoading();
}

final class AdminMoreLoaded extends AdminMoreState {
  const AdminMoreLoaded(this.profile, {this.isSigningOut = false});

  final AdminProfile profile;
  final bool isSigningOut;

  @override
  List<Object?> get props => [profile, isSigningOut];
}

final class AdminMoreFailure extends AdminMoreState {
  const AdminMoreFailure(this.message, {this.reference});

  final String message;
  final String? reference;

  @override
  List<Object?> get props => [message, reference];
}

/// Session ended; the auth guard navigates to the role picker.
final class AdminMoreSignedOut extends AdminMoreState {
  const AdminMoreSignedOut();
}
