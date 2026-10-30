import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/core.dart';
import '../../domain/entities/kyc_applicant.dart';
import '../../domain/usecase/get_kyc_applicant.dart';
import '../../domain/usecase/submit_kyc_decision.dart';

part 'admin_kyc_detail_event.dart';
part 'admin_kyc_detail_state.dart';

class AdminKycDetailBloc
    extends Bloc<AdminKycDetailEvent, AdminKycDetailState> {
  AdminKycDetailBloc(this._getApplicant, this._submitDecision)
    : super(const AdminKycDetailLoading()) {
    on<AdminKycDetailRequested>(_onRequested);
    on<AdminKycDecisionSubmitted>(_onDecisionSubmitted);
  }

  final GetKycApplicant _getApplicant;
  final SubmitKycDecision _submitDecision;

  Future<void> _onRequested(
    AdminKycDetailRequested event,
    Emitter<AdminKycDetailState> emit,
  ) async {
    emit(const AdminKycDetailLoading());
    try {
      emit(AdminKycDetailLoaded(await _getApplicant(event.id)));
    } catch (e) {
      emit(
        AdminKycDetailFailure(errorMessage(e), reference: errorReference(e)),
      );
    }
  }

  Future<void> _onDecisionSubmitted(
    AdminKycDecisionSubmitted event,
    Emitter<AdminKycDetailState> emit,
  ) async {
    final current = state;
    if (current is! AdminKycDetailLoaded || current.isSubmitting) return;
    final draft = KycDecisionDraft(event.decision, event.reason);
    emit(AdminKycDetailLoaded(current.applicant, isSubmitting: true));
    try {
      final updated = await _submitDecision(
        KycDecisionParams(
          applicant: current.applicant,
          decision: event.decision,
          reason: event.reason,
        ),
      );
      emit(AdminKycDetailLoaded(updated, justDecided: true));
    } catch (e) {
      // Keep the admin's choice and reason so the sheet reopens with them.
      emit(
        AdminKycDetailLoaded(
          current.applicant,
          draft: draft,
          errorMessage: errorMessage(e),
          errorReference: errorReference(e),
        ),
      );
    }
  }
}
