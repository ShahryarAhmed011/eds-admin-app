import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/core.dart';
import '../../domain/entities/admin_product_request.dart';
import '../../domain/usecase/get_product_requests_page.dart';

part 'admin_product_requests_list_event.dart';
part 'admin_product_requests_list_state.dart';

/// Loads one status tab at a time; tabs are fetched on first open.
class AdminProductRequestsListBloc
    extends Bloc<AdminProductRequestsListEvent, AdminProductRequestsListState> {
  AdminProductRequestsListBloc(this._getPage)
    : super(const AdminProductRequestsListLoading()) {
    on<AdminProductRequestsListRequested>(_onRequested);
    on<AdminProductRequestsListTabChanged>(_onTabChanged);
    on<AdminProductRequestsListSearchChanged>(_onSearchChanged);
  }

  final GetProductRequestsPage _getPage;

  Future<void> _onRequested(
    AdminProductRequestsListRequested event,
    Emitter<AdminProductRequestsListState> emit,
  ) async {
    emit(const AdminProductRequestsListLoading());
    try {
      const tab = ProductRequestStatus.pending;
      emit(AdminProductRequestsListLoaded(pages: {tab: await _getPage(tab)}));
    } catch (e) {
      emit(
        AdminProductRequestsListFailure(
          errorMessage(e),
          reference: errorReference(e),
        ),
      );
    }
  }

  Future<void> _onTabChanged(
    AdminProductRequestsListTabChanged event,
    Emitter<AdminProductRequestsListState> emit,
  ) async {
    final current = state;
    if (current is! AdminProductRequestsListLoaded) return;
    if (current.pages.containsKey(event.tab)) {
      emit(current.copyWith(tab: event.tab));
      return;
    }
    emit(current.copyWith(tab: event.tab, isTabLoading: true));
    try {
      final page = await _getPage(event.tab);
      final latest = state as AdminProductRequestsListLoaded;
      emit(
        latest.copyWith(
          pages: {...latest.pages, event.tab: page},
          isTabLoading: false,
        ),
      );
    } catch (e) {
      final latest = state as AdminProductRequestsListLoaded;
      emit(latest.copyWith(isTabLoading: false, tabError: errorMessage(e)));
    }
  }

  void _onSearchChanged(
    AdminProductRequestsListSearchChanged event,
    Emitter<AdminProductRequestsListState> emit,
  ) {
    if (state case final AdminProductRequestsListLoaded s) {
      emit(s.copyWith(query: event.query));
    }
  }
}
