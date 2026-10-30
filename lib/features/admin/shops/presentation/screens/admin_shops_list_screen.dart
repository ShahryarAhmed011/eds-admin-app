import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/core.dart';
import '../../../../../core/di/injection.dart';
import '../../../common/admin_common.dart';
import '../../domain/repository/admin_shops_repository.dart';
import '../bloc/admin_shops_list_bloc.dart';
import '../widgets/admin_shop_labels.dart';

class AdminShopsListScreen extends StatelessWidget {
  const AdminShopsListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          sl<AdminShopsListBloc>()..add(const AdminShopsListRequested()),
      child: const _AdminShopsListView(),
    );
  }
}

class _AdminShopsListView extends StatelessWidget {
  const _AdminShopsListView();

  @override
  Widget build(BuildContext context) {
    return EdsScaffold(
      title: 'Manage shops',
      bottomNav: const EdsBottomNav(
        items: RoleNavs.admin,
        currentIndex: AdminTab.shops,
      ),
      body: BlocBuilder<AdminShopsListBloc, AdminShopsListState>(
        builder: (context, state) => switch (state) {
          AdminShopsListLoading() => const EdsLoadingView(),
          AdminShopsListFailure(:final message, :final reference) =>
            EdsErrorView(
              message: message,
              reference: reference,
              onRetry: () => context.read<AdminShopsListBloc>().add(
                const AdminShopsListRequested(),
              ),
            ),
          final AdminShopsListLoaded loaded => _ShopsListContent(loaded),
        },
      ),
    );
  }
}

class _ShopsListContent extends StatelessWidget {
  const _ShopsListContent(this.state);

  final AdminShopsListLoaded state;

  static String _count(int? n) => switch (n) {
    null => '',
    >= AdminShopsRepository.pageLimit =>
      ' · ${AdminShopsRepository.pageLimit}+',
    _ => ' · $n',
  };

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<AdminShopsListBloc>();
    final shops = state.visibleItems;
    final total = _count(state.countFor(state.tab)).replaceFirst(' · ', '');
    final of = total.isEmpty ? '' : ' of $total';
    final (title, subtitle, footer) = switch (state.tab) {
      ShopsListTab.all => (
        total.isEmpty ? 'All shops' : '$total shops',
        'All statuses',
        'Showing ${shops.length}$of shops.',
      ),
      ShopsListTab.ready => (
        total.isEmpty ? 'Ready for activation' : '$total ready for activation',
        'KYC approved · Catalogue complete',
        'Showing ${shops.length}$of ready shops. Confirm serviceability and '
            'hours before setting live.',
      ),
      ShopsListTab.flagged => (
        total.isEmpty ? 'Flagged shops' : '$total flagged shops',
        'Complaints and suspensions',
        'Showing ${shops.length}$of flagged shops. Review complaints before '
            'changing status.',
      ),
    };
    return AdminFilteredList(
      searchHint: 'Search shop, owner or ID',
      onSearchChanged: (q) => bloc.add(AdminShopsListSearchChanged(q)),
      tabLabels: [
        'All${_count(state.countFor(ShopsListTab.all))}',
        'Ready${_count(state.countFor(ShopsListTab.ready))}',
        'Flagged${_count(state.countFor(ShopsListTab.flagged))}',
      ],
      selectedTab: state.tab.index,
      onTabChanged: (i) =>
          bloc.add(AdminShopsListTabChanged(ShopsListTab.values[i])),
      title: title,
      subtitle: subtitle,
      emptyMessage: state.query.trim().isEmpty
          ? 'No shops in this list.'
          : 'No shop matches your search.',
      footer: Text(footer, style: AppTextStyles.bodySecondary),
      children: [
        for (final shop in shops)
          AdminRecordTile(
            title: shop.name,
            subtitle: shop.listSubtitle,
            badge: shop.badgeLabel,
            badgeTone: shop.badgeTone,
            onTap: () async {
              await context.push(
                '${AppRoutes.adminShopDetail}?id=${Uri.encodeComponent(shop.id)}',
              );
              bloc.add(const AdminShopsListRequested());
            },
          ),
      ],
    );
  }
}
