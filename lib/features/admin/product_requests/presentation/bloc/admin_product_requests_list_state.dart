part of 'admin_product_requests_list_bloc.dart';

sealed class AdminProductRequestsListState extends Equatable {
  const AdminProductRequestsListState();

  @override
  List<Object?> get props => [];
}

final class AdminProductRequestsListLoading
    extends AdminProductRequestsListState {
  const AdminProductRequestsListLoading();
}

final class AdminProductRequestsListLoaded
    extends AdminProductRequestsListState {
  const AdminProductRequestsListLoaded({
    required this.pages,
    this.tab = ProductRequestStatus.pending,
    this.query = '',
    this.isTabLoading = false,
    this.tabError,
  });

  /// Loaded pages per status tab.
  final Map<ProductRequestStatus, ProductRequestsPage> pages;

  /// Tabs map 1:1 to request statuses.
  final ProductRequestStatus tab;
  final String query;
  final bool isTabLoading;

  /// Set when the selected tab failed to load.
  final String? tabError;

  ProductRequestsPage? get page => pages[tab];

  /// Count for a tab, or null while it has not been loaded.
  int? countFor(ProductRequestStatus status) => pages[status]?.count;

  List<ProductRequestSummary> get visibleItems {
    final q = query.trim().toLowerCase();
    return [
      for (final request in page?.items ?? const <ProductRequestSummary>[])
        if (request.status == tab &&
            (q.isEmpty ||
                request.displayName.toLowerCase().contains(q) ||
                request.shopLabel.toLowerCase().contains(q) ||
                request.code.toLowerCase().contains(q)))
          request,
    ];
  }

  AdminProductRequestsListLoaded copyWith({
    Map<ProductRequestStatus, ProductRequestsPage>? pages,
    ProductRequestStatus? tab,
    String? query,
    bool? isTabLoading,
    String? tabError,
  }) => AdminProductRequestsListLoaded(
    pages: pages ?? this.pages,
    tab: tab ?? this.tab,
    query: query ?? this.query,
    isTabLoading: isTabLoading ?? this.isTabLoading,
    tabError: tabError,
  );

  @override
  List<Object?> get props => [pages, tab, query, isTabLoading, tabError];
}

final class AdminProductRequestsListFailure
    extends AdminProductRequestsListState {
  const AdminProductRequestsListFailure(this.message, {this.reference});

  final String message;
  final String? reference;

  @override
  List<Object?> get props => [message, reference];
}
