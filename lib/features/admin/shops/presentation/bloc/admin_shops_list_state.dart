part of 'admin_shops_list_bloc.dart';

enum ShopsListTab { all, ready, flagged }

sealed class AdminShopsListState extends Equatable {
  const AdminShopsListState();

  @override
  List<Object?> get props => [];
}

final class AdminShopsListLoading extends AdminShopsListState {
  const AdminShopsListLoading();
}

final class AdminShopsListLoaded extends AdminShopsListState {
  const AdminShopsListLoaded({
    required this.lists,
    this.tab = ShopsListTab.ready,
    this.query = '',
  });

  /// Shops per tab; null when that tab failed to load.
  final Map<ShopsListTab, List<AdminShop>?> lists;
  final ShopsListTab tab;
  final String query;

  /// Count for a tab label, or null when unknown.
  int? countFor(ShopsListTab tab) => lists[tab]?.length;

  /// Search matches shop name, ID, owner or area.
  List<AdminShop> get visibleItems {
    final q = query.trim().toLowerCase();
    final shops = lists[tab] ?? const <AdminShop>[];
    if (q.isEmpty) return shops;
    return [
      for (final shop in shops)
        if ([
          shop.name,
          shop.reference,
          shop.ownerName ?? '',
          shop.areaName ?? '',
          shop.landmark ?? '',
        ].join(' ').toLowerCase().contains(q))
          shop,
    ];
  }

  AdminShopsListLoaded copyWith({ShopsListTab? tab, String? query}) =>
      AdminShopsListLoaded(
        lists: lists,
        tab: tab ?? this.tab,
        query: query ?? this.query,
      );

  @override
  List<Object?> get props => [lists, tab, query];
}

final class AdminShopsListFailure extends AdminShopsListState {
  const AdminShopsListFailure(this.message, {this.reference});

  final String message;
  final String? reference;

  @override
  List<Object?> get props => [message, reference];
}
