import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/core.dart';

import '../../domain/entities/admin_product_request.dart';
import '../../domain/usecase/get_product_request.dart';
import '../../domain/usecase/submit_product_request_decision.dart';

part 'admin_product_request_detail_event.dart';
part 'admin_product_request_detail_state.dart';

class AdminProductRequestDetailBloc
    extends
        Bloc<AdminProductRequestDetailEvent, AdminProductRequestDetailState> {
  AdminProductRequestDetailBloc(this._getRequest, this._submitDecision)
    : super(const AdminProductRequestDetailLoading()) {
    on<AdminProductRequestDetailRequested>(_onRequested);
    on<AdminProductRequestDecisionSubmitted>(_onDecisionSubmitted);
  }

  final GetProductRequest _getRequest;
  final SubmitProductRequestDecision _submitDecision;

  Future<void> _onRequested(
    AdminProductRequestDetailRequested event,
    Emitter<AdminProductRequestDetailState> emit,
  ) async {
    emit(const AdminProductRequestDetailLoading());
    try {
      emit(AdminProductRequestDetailLoaded(await _getRequest(event.id)));
    } catch (e) {
      emit(
        AdminProductRequestDetailFailure(
          errorMessage(e),
          reference: errorReference(e),
        ),
      );
    }
  }

  Future<void> _onDecisionSubmitted(
    AdminProductRequestDecisionSubmitted event,
    Emitter<AdminProductRequestDetailState> emit,
  ) async {
    final current = state;
    if (current is! AdminProductRequestDetailLoaded) return;
    emit(AdminProductRequestDetailLoaded(current.request, isSubmitting: true));
    try {
      final status = await _submitDecision(
        ProductRequestDecisionParams(
          request: current.request,
          decision: event.decision,
          reason: event.reason,
        ),
      );
      emit(
        AdminProductRequestDetailLoaded(
          current.request.copyWith(status: status),
          lastDecision: event.decision,
        ),
      );
    } catch (e) {
      // Keep the request on screen and surface the error.
      emit(
        AdminProductRequestDetailLoaded(
          current.request,
          actionError: errorMessage(e),
        ),
      );
    }
  }
}
