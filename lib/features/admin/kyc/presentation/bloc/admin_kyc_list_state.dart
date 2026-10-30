part of 'admin_kyc_list_bloc.dart';

enum KycListTab { all, retailers, riders }

sealed class AdminKycListState extends Equatable {
  const AdminKycListState();

  @override
  List<Object?> get props => [];
}

final class AdminKycListLoading extends AdminKycListState {
  const AdminKycListLoading();
}

final class AdminKycListLoaded extends AdminKycListState {
  const AdminKycListLoaded({
    required this.items,
    this.tab = KycListTab.all,
    this.query = '',
  });

  /// Pending reviews, oldest first.
  final List<KycApplicant> items;
  final KycListTab tab;
  final String query;

  int countFor(KycListTab tab) => items.where((i) => _inTab(i, tab)).length;

  List<KycApplicant> get visibleItems {
    final q = query.trim().toLowerCase();
    return [
      for (final item in items)
        if (_inTab(item, tab) &&
            (q.isEmpty ||
                item.name.toLowerCase().contains(q) ||
                item.reference.toLowerCase().contains(q)))
          item,
    ];
  }

  static bool _inTab(KycApplicant item, KycListTab tab) => switch (tab) {
    KycListTab.all => true,
    KycListTab.retailers => item.role == KycApplicantRole.retailer,
    KycListTab.riders => item.role == KycApplicantRole.rider,
  };

  AdminKycListLoaded copyWith({KycListTab? tab, String? query}) =>
      AdminKycListLoaded(
        items: items,
        tab: tab ?? this.tab,
        query: query ?? this.query,
      );

  @override
  List<Object?> get props => [items, tab, query];
}

final class AdminKycListFailure extends AdminKycListState {
  const AdminKycListFailure(this.message, {this.reference});

  final String message;
  final String? reference;

  @override
  List<Object?> get props => [message, reference];
}
