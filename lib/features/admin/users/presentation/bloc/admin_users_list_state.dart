part of 'admin_users_list_bloc.dart';

enum UsersListTab { all, flagged, suspended }

sealed class AdminUsersListState extends Equatable {
  const AdminUsersListState();

  @override
  List<Object?> get props => [];
}

final class AdminUsersListLoading extends AdminUsersListState {
  const AdminUsersListLoading();
}

final class AdminUsersListLoaded extends AdminUsersListState {
  const AdminUsersListLoaded({
    required this.lists,
    this.tab = UsersListTab.flagged,
    this.query = '',
    this.searchResults,
  });

  /// Users per tab; null when that tab failed to load.
  final Map<UsersListTab, List<AdminUser>?> lists;
  final UsersListTab tab;
  final String query;

  /// Server-side search results for [query] in [tab], once they arrive.
  final List<AdminUser>? searchResults;

  /// Count for a tab label, or null when unknown.
  int? countFor(UsersListTab tab) => lists[tab]?.length;

  List<AdminUser> get visibleItems {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return lists[tab] ?? const [];
    if (searchResults != null) return searchResults!;
    return [
      for (final user in lists[tab] ?? const <AdminUser>[])
        if ('${user.name} ${user.email} ${user.reference} ${user.phone ?? ''}'
            .toLowerCase()
            .contains(q))
          user,
    ];
  }

  AdminUsersListLoaded copyWith({
    UsersListTab? tab,
    String? query,
    List<AdminUser>? searchResults,
    bool clearSearchResults = false,
  }) => AdminUsersListLoaded(
    lists: lists,
    tab: tab ?? this.tab,
    query: query ?? this.query,
    searchResults: clearSearchResults
        ? null
        : (searchResults ?? this.searchResults),
  );

  @override
  List<Object?> get props => [lists, tab, query, searchResults];
}

final class AdminUsersListFailure extends AdminUsersListState {
  const AdminUsersListFailure(this.message, {this.reference});

  final String message;
  final String? reference;

  @override
  List<Object?> get props => [message, reference];
}
