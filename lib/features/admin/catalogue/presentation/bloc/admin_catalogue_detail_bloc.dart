import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/core.dart';

import '../../domain/entities/admin_catalogue_variant.dart';
import '../../domain/usecase/get_catalogue_variant.dart';
import '../../domain/usecase/submit_catalogue_variant_action.dart';

part 'admin_catalogue_detail_event.dart';
part 'admin_catalogue_detail_state.dart';

class AdminCatalogueDetailBloc
    extends Bloc<AdminCatalogueDetailEvent, AdminCatalogueDetailState> {
  AdminCatalogueDetailBloc(this._getVariant, this._submitAction)
    : super(const AdminCatalogueDetailLoading()) {
    on<AdminCatalogueDetailRequested>(_onRequested);
    on<AdminCatalogueVariantActionSubmitted>(_onActionSubmitted);
  }

  final GetCatalogueVariant _getVariant;
  final SubmitCatalogueVariantAction _submitAction;

  Future<void> _onRequested(
    AdminCatalogueDetailRequested event,
    Emitter<AdminCatalogueDetailState> emit,
  ) async {
    emit(const AdminCatalogueDetailLoading());
    try {
      emit(AdminCatalogueDetailLoaded(await _getVariant(event.id)));
    } catch (e) {
      emit(
        AdminCatalogueDetailFailure(
          errorMessage(e),
          reference: errorReference(e),
        ),
      );
    }
  }

  Future<void> _onActionSubmitted(
    AdminCatalogueVariantActionSubmitted event,
    Emitter<AdminCatalogueDetailState> emit,
  ) async {
    final current = state;
    if (current is! AdminCatalogueDetailLoaded) return;
    emit(AdminCatalogueDetailLoaded(current.variant, isSubmitting: true));
    try {
      await _submitAction(
        CatalogueVariantActionParams(
          id: current.variant.summary.id,
          action: event.action,
          reason: event.reason,
        ),
      );
      final status = switch (event.action) {
        CatalogueVariantAction.approve => CatalogueVariantStatus.active,
        CatalogueVariantAction.deactivate => CatalogueVariantStatus.inactive,
        CatalogueVariantAction.markDuplicate =>
          CatalogueVariantStatus.duplicate,
      };
      emit(
        AdminCatalogueDetailLoaded(
          current.variant.copyWith(status: status, needsReview: false),
          lastAction: event.action,
        ),
      );
    } catch (e) {
      // Keep the variant on screen and surface the error.
      emit(
        AdminCatalogueDetailLoaded(
          current.variant,
          actionError: errorMessage(e),
        ),
      );
    }
  }
}
