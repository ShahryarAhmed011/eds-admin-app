import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/core.dart';
import '../../domain/entities/admin_user.dart';
import '../../domain/usecase/get_admin_users.dart';

part 'admin_users_list_event.dart';
part 'admin_users_list_state.dart';

class AdminUsersListBloc
    extends Bloc<AdminUsersListEvent, AdminUsersListState> {
  AdminUsersListBloc(this._getUsers, {this.searchDebounce = _debounce})
    : super(const AdminUsersListLoading()) {
    on<AdminUsersListRequested>(_onRequested);
    on<AdminUsersListTabChanged>(_onTabChanged);
    on<AdminUsersListSearchChanged>(_onSearchChanged);
  }

  static const _debounce = Duration(milliseconds: 350);

  final GetAdminUsers _getUsers;
  final Duration searchDebounce;

  static AdminUserStatus? statusFor(UsersListTab tab) => switch (tab) {
    UsersListTab.all => null,
    UsersListTab.flagged => AdminUserStatus.flagged,
    UsersListTab.suspended => AdminUserStatus.suspended,
  };

  /// Loads every tab in parallel so each tab label can show its count.
  /// A failing tab is tolerated unless it is the selected one.
  Future<void> _onRequested(
    AdminUsersListRequested event,
    Emitter<AdminUsersListState> emit,
  ) async {
    final previous = state;
    if (previous is! AdminUsersListLoaded) emit(const AdminUsersListLoading());
    final selected = previous is AdminUsersListLoaded
        ? previous.tab
        : UsersListTab.flagged;
    Object? selectedError;
    final lists = await Future.wait([
      for (final tab in UsersListTab.values)
        _getUsers(
          AdminUsersQuery(status: statusFor(tab)),
        ).then<List<AdminUser>?>(
          (users) => users,
          onError: (Object e) {
            if (tab == selected) selectedError = e;
            return null;
          },
        ),
    ]);
    if (selectedError != null) {
      emit(
        AdminUsersListFailure(
          errorMessage(selectedError!),
          reference: errorReference(selectedError!),
        ),
      );
      return;
    }
    emit(
      AdminUsersListLoaded(
        lists: {
          for (var i = 0; i < UsersListTab.values.length; i++)
            UsersListTab.values[i]: lists[i],
        },
        tab: selected,
        query: previous is AdminUsersListLoaded ? previous.query : '',
      ),
    );
    if (previous is AdminUsersListLoaded && previous.query.isNotEmpty) {
      add(AdminUsersListSearchChanged(previous.query));
    }
  }

  void _onTabChanged(
    AdminUsersListTabChanged event,
    Emitter<AdminUsersListState> emit,
  ) {
    if (state case final AdminUsersListLoaded s) {
      emit(s.copyWith(tab: event.tab, clearSearchResults: true));
      if (s.query.trim().isNotEmpty) add(AdminUsersListSearchChanged(s.query));
    }
  }

  /// Filters locally right away, then asks the server (`q`) after a pause.
  Future<void> _onSearchChanged(
    AdminUsersListSearchChanged event,
    Emitter<AdminUsersListState> emit,
  ) async {
    final s = state;
    if (s is! AdminUsersListLoaded) return;
    emit(s.copyWith(query: event.query, clearSearchResults: true));
    final q = event.query.trim();
    if (q.isEmpty) return;
    await Future<void>.delayed(searchDebounce);
    final latest = state;
    if (latest is! AdminUsersListLoaded || latest.query != event.query) return;
    try {
      final results = await _getUsers(
        AdminUsersQuery(status: statusFor(latest.tab), query: q),
      );
      final now = state;
      if (now is AdminUsersListLoaded &&
          now.query == event.query &&
          now.tab == latest.tab) {
        emit(now.copyWith(searchResults: results));
      }
    } catch (_) {
      // Keep the local filter; the list is still usable.
    }
  }
}
