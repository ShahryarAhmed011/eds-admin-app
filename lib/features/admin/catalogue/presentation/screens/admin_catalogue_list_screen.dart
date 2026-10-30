import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/core.dart';
import '../../../../../core/di/injection.dart';
import '../../../common/admin_common.dart';
import '../bloc/admin_catalogue_list_bloc.dart';
import '../widgets/catalogue_variant_labels.dart';

class AdminCatalogueListScreen extends StatelessWidget {
  const AdminCatalogueListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          sl<AdminCatalogueListBloc>()
            ..add(const AdminCatalogueListRequested()),
      child: const _AdminCatalogueListView(),
    );
  }
}

class _AdminCatalogueListView extends StatelessWidget {
  const _AdminCatalogueListView();

  @override
  Widget build(BuildContext context) {
    return EdsScaffold(
      title: 'Catalogue variants',
      bottomNav: const EdsBottomNav(
        items: RoleNavs.admin,
        currentIndex: AdminTab.catalogue,
      ),
      body: BlocBuilder<AdminCatalogueListBloc, AdminCatalogueListState>(
        builder: (context, state) => switch (state) {
          AdminCatalogueListLoading() => const EdsLoadingView(),
          AdminCatalogueListFailure(:final message, :final reference) =>
            EdsErrorView(
              message: message,
              reference: reference,
              onRetry: () => context.read<AdminCatalogueListBloc>().add(
                const AdminCatalogueListRequested(),
              ),
            ),
          final AdminCatalogueListLoaded loaded => _CatalogueListContent(
            loaded,
          ),
        },
      ),
    );
  }
}

class _CatalogueListContent extends StatelessWidget {
  const _CatalogueListContent(this.state);

  final AdminCatalogueListLoaded state;

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<AdminCatalogueListBloc>();
    final page = state.page;
    final variants = state.visibleItems;
    final (title, subtitle) = switch (state.tab) {
      CatalogueListTab.all => (
        '${_count(page.totalCount)} variants',
        'Showing ${variants.length} of ${_count(page.totalCount)} · '
            'Global catalogue',
      ),
      CatalogueListTab.review => (
        '${page.reviewCount} variants need review',
        'Showing ${variants.length} of ${page.reviewCount} · Global catalogue',
      ),
      CatalogueListTab.inactive => (
        '${page.inactiveCount} inactive variants',
        'Showing ${variants.length} of ${page.inactiveCount} · '
            'Hidden from shops',
      ),
    };
    return AdminFilteredList(
      searchHint: 'Search name, SKU or barcode',
      onSearchChanged: (q) => bloc.add(AdminCatalogueListSearchChanged(q)),
      tabLabels: [
        'All · ${_count(page.totalCount)}',
        'Review · ${page.reviewCount}',
        'Inactive · ${page.inactiveCount}',
      ],
      selectedTab: state.tab.index,
      onTabChanged: (i) =>
          bloc.add(AdminCatalogueListTabChanged(CatalogueListTab.values[i])),
      title: title,
      subtitle: subtitle,
      footer: const EdsBanner(
        title: 'Global changes affect every shop',
        message:
            'Review linked listings before editing or deactivating a variant.',
        tone: EdsTone.warning,
      ),
      children: [
        for (final variant in variants)
          AdminRecordTile(
            title: variant.displayName,
            subtitle: [
              variant.skuCode,
              ?variant.category,
              ?variant.listNote,
            ].join(' · '),
            badge: variant.badgeLabel,
            badgeTone: variant.badgeTone,
            onTap: () => context.push(
              '${AppRoutes.adminCatalogueVariantDetail}?id=${variant.id}',
            ),
          ),
      ],
    );
  }

  /// 1248 → "1,248".
  static String _count(int value) => value.toString().replaceAllMapped(
    RegExp(r'\B(?=(\d{3})+(?!\d))'),
    (_) => ',',
  );
}
