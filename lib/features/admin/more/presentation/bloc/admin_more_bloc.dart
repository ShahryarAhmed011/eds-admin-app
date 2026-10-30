import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/core.dart';
import '../../../../shared/auth/domain/usecase/logout_use_case.dart';
import '../../domain/entities/admin_profile.dart';
import '../../domain/usecase/get_admin_profile.dart';

part 'admin_more_event.dart';
part 'admin_more_state.dart';

class AdminMoreBloc extends Bloc<AdminMoreEvent, AdminMoreState> {
  AdminMoreBloc(this._getProfile, this._logout)
    : super(const AdminMoreLoading()) {
    on<AdminMoreRequested>(_onRequested);
    on<AdminMoreSignOutRequested>(_onSignOut);
  }

  final GetAdminProfile _getProfile;
  final LogoutUseCase _logout;

  /// `POST /auth/logout` + clear tokens (never throws); the router's auth
  /// guard then leaves the admin area.
  Future<void> _onSignOut(
    AdminMoreSignOutRequested event,
    Emitter<AdminMoreState> emit,
  ) async {
    final current = state;
    if (current is AdminMoreLoaded) {
      if (current.isSigningOut) return;
      emit(AdminMoreLoaded(current.profile, isSigningOut: true));
    }
    await _logout(const NoParams());
    emit(const AdminMoreSignedOut());
  }

  Future<void> _onRequested(
    AdminMoreRequested event,
    Emitter<AdminMoreState> emit,
  ) async {
    emit(const AdminMoreLoading());
    try {
      emit(AdminMoreLoaded(await _getProfile(const NoParams())));
    } catch (e) {
      emit(AdminMoreFailure(errorMessage(e), reference: errorReference(e)));
    }
  }
}
