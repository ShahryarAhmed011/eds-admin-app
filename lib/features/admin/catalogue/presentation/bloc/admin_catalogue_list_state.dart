part of 'admin_catalogue_list_bloc.dart';

enum CatalogueListTab { all, review, inactive }

sealed class AdminCatalogueListState extends Equatable {
  const AdminCatalogueListState();

  @override
  List<Object?> get props => [];
}

final class AdminCatalogueListLoading extends AdminCatalogueListState {
  const AdminCatalogueListLoading();
}

final class AdminCatalogueListLoaded extends AdminCatalogueListState {
  const AdminCatalogueListLoaded({
    required this.page,
    this.tab = CatalogueListTab.review,
    this.query = '',
  });

  final CatalogueVariantsPage page;
  final CatalogueListTab tab;
  final String query;

  List<CatalogueVariantSummary> get visibleItems {
    final q = query.trim().toLowerCase();
    return [
      for (final variant in page.items)
        if (_matchesTab(variant) &&
            (q.isEmpty ||
                variant.displayName.toLowerCase().contains(q) ||
                variant.skuCode.toLowerCase().contains(q) ||
                (variant.category?.toLowerCase().contains(q) ?? false)))
          variant,
    ];
  }

  bool _matchesTab(CatalogueVariantSummary variant) => switch (tab) {
    CatalogueListTab.all => true,
    CatalogueListTab.review => variant.needsReview,
    CatalogueListTab.inactive =>
      variant.status != CatalogueVariantStatus.active,
  };

  AdminCatalogueListLoaded copyWith({CatalogueListTab? tab, String? query}) =>
      AdminCatalogueListLoaded(
        page: page,
        tab: tab ?? this.tab,
        query: query ?? this.query,
      );

  @override
  List<Object?> get props => [page, tab, query];
}

final class AdminCatalogueListFailure extends AdminCatalogueListState {
  const AdminCatalogueListFailure(this.message, {this.reference});

  final String message;
  final String? reference;

  @override
  List<Object?> get props => [message, reference];
}
