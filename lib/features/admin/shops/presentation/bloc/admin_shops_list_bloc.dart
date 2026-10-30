import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/core.dart';
import '../../domain/entities/admin_shop.dart';
import '../../domain/repository/admin_shops_repository.dart';
import '../../domain/usecase/get_admin_shops.dart';

part 'admin_shops_list_event.dart';
part 'admin_shops_list_state.dart';

class AdminShopsListBloc
    extends Bloc<AdminShopsListEvent, AdminShopsListState> {
  AdminShopsListBloc(this._getShops) : super(const AdminShopsListLoading()) {
    on<AdminShopsListRequested>(_onRequested);
    on<AdminShopsListTabChanged>(_onTabChanged);
    on<AdminShopsListSearchChanged>(_onSearchChanged);
  }

  final GetAdminShops _getShops;

  static AdminShopsFilter filterFor(ShopsListTab tab) => switch (tab) {
    ShopsListTab.all => AdminShopsFilter.all,
    ShopsListTab.ready => AdminShopsFilter.ready,
    ShopsListTab.flagged => AdminShopsFilter.needsAttention,
  };

  /// Loads every tab in parallel so each tab label can show its count.
  /// A failing tab is tolerated unless it is the selected one.
  Future<void> _onRequested(
    AdminShopsListRequested event,
    Emitter<AdminShopsListState> emit,
  ) async {
    final previous = state;
    if (previous is! AdminShopsListLoaded) emit(const AdminShopsListLoading());
    final selected = previous is AdminShopsListLoaded
        ? previous.tab
        : ShopsListTab.ready;
    Object? selectedError;
    final lists = await Future.wait([
      for (final tab in ShopsListTab.values)
        _getShops(filterFor(tab)).then<List<AdminShop>?>(
          (shops) => shops,
          onError: (Object e) {
            if (tab == selected) selectedError = e;
            return null;
          },
        ),
    ]);
    if (selectedError != null) {
      emit(
        AdminShopsListFailure(
          errorMessage(selectedError!),
          reference: errorReference(selectedError!),
        ),
      );
      return;
    }
    emit(
      AdminShopsListLoaded(
        lists: {
          for (var i = 0; i < ShopsListTab.values.length; i++)
            ShopsListTab.values[i]: lists[i],
        },
        tab: selected,
        query: previous is AdminShopsListLoaded ? previous.query : '',
      ),
    );
  }

  void _onTabChanged(
    AdminShopsListTabChanged event,
    Emitter<AdminShopsListState> emit,
  ) {
    if (state case final AdminShopsListLoaded s) {
      emit(s.copyWith(tab: event.tab));
    }
  }

  /// The API has no search parameter; filtering is local.
  void _onSearchChanged(
    AdminShopsListSearchChanged event,
    Emitter<AdminShopsListState> emit,
  ) {
    if (state case final AdminShopsListLoaded s) {
      emit(s.copyWith(query: event.query));
    }
  }
}
