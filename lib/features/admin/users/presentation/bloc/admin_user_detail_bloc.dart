import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/core.dart';
import '../../domain/entities/admin_user.dart';
import '../../domain/usecase/get_admin_user.dart';
import '../../domain/usecase/submit_user_access_decision.dart';

part 'admin_user_detail_event.dart';
part 'admin_user_detail_state.dart';

class AdminUserDetailBloc
    extends Bloc<AdminUserDetailEvent, AdminUserDetailState> {
  AdminUserDetailBloc(this._getUser, this._submitDecision)
    : super(const AdminUserDetailLoading()) {
    on<AdminUserDetailRequested>(_onRequested);
    on<AdminUserAccessDecisionSubmitted>(_onDecisionSubmitted);
  }

  final GetAdminUser _getUser;
  final SubmitUserAccessDecision _submitDecision;

  Future<void> _onRequested(
    AdminUserDetailRequested event,
    Emitter<AdminUserDetailState> emit,
  ) async {
    emit(const AdminUserDetailLoading());
    try {
      emit(AdminUserDetailLoaded(await _getUser(event.id)));
    } catch (e) {
      emit(
        AdminUserDetailFailure(errorMessage(e), reference: errorReference(e)),
      );
    }
  }

  Future<void> _onDecisionSubmitted(
    AdminUserAccessDecisionSubmitted event,
    Emitter<AdminUserDetailState> emit,
  ) async {
    final current = state;
    if (current is! AdminUserDetailLoaded || current.isSubmitting) return;
    emit(AdminUserDetailLoaded(current.user, isSubmitting: true));
    try {
      final updated = await _submitDecision(
        UserAccessDecisionParams(
          user: current.user,
          action: event.action,
          reason: event.reason,
        ),
      );
      emit(AdminUserDetailLoaded(updated, lastAction: event.action));
    } catch (e) {
      // Keep the choice and reason so the sheet reopens with them.
      emit(
        AdminUserDetailLoaded(
          current.user,
          draft: (action: event.action, reason: event.reason),
          errorMessage: errorMessage(e),
          errorReference: errorReference(e),
        ),
      );
    }
  }
}
