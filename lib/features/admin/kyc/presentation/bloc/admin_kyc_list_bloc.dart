import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/core.dart';
import '../../domain/entities/kyc_applicant.dart';
import '../../domain/usecase/get_kyc_review_queue.dart';

part 'admin_kyc_list_event.dart';
part 'admin_kyc_list_state.dart';

class AdminKycListBloc extends Bloc<AdminKycListEvent, AdminKycListState> {
  AdminKycListBloc(this._getQueue) : super(const AdminKycListLoading()) {
    on<AdminKycListRequested>(_onRequested);
    on<AdminKycListTabChanged>(_onTabChanged);
    on<AdminKycListSearchChanged>(_onSearchChanged);
  }

  final GetKycReviewQueue _getQueue;

  Future<void> _onRequested(
    AdminKycListRequested event,
    Emitter<AdminKycListState> emit,
  ) async {
    // Silent refresh when data is already on screen.
    if (state is! AdminKycListLoaded) emit(const AdminKycListLoading());
    try {
      emit(AdminKycListLoaded(items: await _getQueue(const NoParams())));
    } catch (e) {
      emit(AdminKycListFailure(errorMessage(e), reference: errorReference(e)));
    }
  }

  void _onTabChanged(
    AdminKycListTabChanged event,
    Emitter<AdminKycListState> emit,
  ) {
    if (state case final AdminKycListLoaded s) {
      emit(s.copyWith(tab: event.tab));
    }
  }

  void _onSearchChanged(
    AdminKycListSearchChanged event,
    Emitter<AdminKycListState> emit,
  ) {
    if (state case final AdminKycListLoaded s) {
      emit(s.copyWith(query: event.query));
    }
  }
}
