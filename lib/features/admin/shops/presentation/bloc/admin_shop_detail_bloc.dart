import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/core.dart';
import '../../domain/entities/admin_shop.dart';
import '../../domain/usecase/get_admin_shop.dart';
import '../../domain/usecase/submit_shop_status_decision.dart';

part 'admin_shop_detail_event.dart';
part 'admin_shop_detail_state.dart';

class AdminShopDetailBloc
    extends Bloc<AdminShopDetailEvent, AdminShopDetailState> {
  AdminShopDetailBloc(this._getShop, this._submitDecision)
    : super(const AdminShopDetailLoading()) {
    on<AdminShopDetailRequested>(_onRequested);
    on<AdminShopStatusDecisionSubmitted>(_onDecisionSubmitted);
  }

  final GetAdminShop _getShop;
  final SubmitShopStatusDecision _submitDecision;

  Future<void> _onRequested(
    AdminShopDetailRequested event,
    Emitter<AdminShopDetailState> emit,
  ) async {
    emit(const AdminShopDetailLoading());
    try {
      emit(AdminShopDetailLoaded(await _getShop(event.id)));
    } catch (e) {
      emit(
        AdminShopDetailFailure(errorMessage(e), reference: errorReference(e)),
      );
    }
  }

  Future<void> _onDecisionSubmitted(
    AdminShopStatusDecisionSubmitted event,
    Emitter<AdminShopDetailState> emit,
  ) async {
    final current = state;
    if (current is! AdminShopDetailLoaded || current.isSubmitting) return;
    emit(AdminShopDetailLoaded(current.shop, isSubmitting: true));
    try {
      final updated = await _submitDecision(
        ShopStatusDecisionParams(
          shop: current.shop,
          action: event.action,
          reason: event.reason,
        ),
      );
      emit(AdminShopDetailLoaded(updated, lastAction: event.action));
    } catch (e) {
      // Keep the choice and reason so the sheet reopens with them.
      emit(
        AdminShopDetailLoaded(
          current.shop,
          draft: (action: event.action, reason: event.reason),
          errorMessage: errorMessage(e),
          errorReference: errorReference(e),
        ),
      );
    }
  }
}
