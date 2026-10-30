import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/core.dart';
import '../../../../../core/di/injection.dart';
import '../../../common/admin_common.dart';
import '../../domain/entities/admin_product_request.dart';
import '../bloc/admin_product_requests_list_bloc.dart';
import '../widgets/product_request_labels.dart';

class AdminProductRequestsListScreen extends StatelessWidget {
  const AdminProductRequestsListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          sl<AdminProductRequestsListBloc>()
            ..add(const AdminProductRequestsListRequested()),
      child: const _AdminProductRequestsListView(),
    );
  }
}

class _AdminProductRequestsListView extends StatelessWidget {
  const _AdminProductRequestsListView();

  @override
  Widget build(BuildContext context) {
    return EdsScaffold(
      title: 'Product requests',
      bottomNav: const EdsBottomNav(
        items: RoleNavs.admin,
        currentIndex: AdminTab.queues,
      ),
      body:
          BlocBuilder<
            AdminProductRequestsListBloc,
            AdminProductRequestsListState
          >(
            builder: (context, state) => switch (state) {
              AdminProductRequestsListLoading() => const EdsLoadingView(),
              AdminProductRequestsListFailure(
                :final message,
                :final reference,
              ) =>
                EdsErrorView(
                  message: message,
                  reference: reference,
                  onRetry: () => context
                      .read<AdminProductRequestsListBloc>()
                      .add(const AdminProductRequestsListRequested()),
                ),
              final AdminProductRequestsListLoaded loaded =>
                _RequestsListContent(loaded),
            },
          ),
    );
  }
}

class _RequestsListContent extends StatelessWidget {
  const _RequestsListContent(this.state);

  final AdminProductRequestsListLoaded state;

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<AdminProductRequestsListBloc>();
    final requests = state.visibleItems;
    final count = state.countFor(state.tab) ?? 0;
    final showing = 'Showing ${requests.length} of $count';
    final (title, subtitle) = switch (state.tab) {
      ProductRequestStatus.pending => (
        '$count requests awaiting decision',
        'Newest first · $showing',
      ),
      ProductRequestStatus.approved => (
        '$count approved requests',
        'Added to the global catalogue · $showing',
      ),
      ProductRequestStatus.rejected => (
        '$count rejected requests',
        'Retailers were notified · $showing',
      ),
    };
    String tabLabel(ProductRequestStatus status) {
      final n = state.countFor(status);
      // Figma shows the count on the pending tab only.
      return status == ProductRequestStatus.pending && n != null
          ? '${status.label} · $n'
          : status.label;
    }

    return AdminFilteredList(
      searchHint: 'Search product, shop or request',
      onSearchChanged: (q) =>
          bloc.add(AdminProductRequestsListSearchChanged(q)),
      tabLabels: [for (final s in ProductRequestStatus.values) tabLabel(s)],
      selectedTab: state.tab.index,
      onTabChanged: (i) => bloc.add(
        AdminProductRequestsListTabChanged(ProductRequestStatus.values[i]),
      ),
      title: state.isTabLoading ? 'Loading requests…' : title,
      subtitle: state.isTabLoading ? null : subtitle,
      emptyMessage: state.tabError ?? 'No requests match your search.',
      footer: Text(
        'Check barcode and pack size against existing variants before '
        'approving a new catalogue entry.',
        style: AppTextStyles.bodySecondary,
      ),
      children: [
        for (final request in requests)
          AdminRecordTile(
            title: request.displayName,
            subtitle: '${request.code} · ${request.shopLabel}',
            badge: request.status.label,
            badgeTone: request.status.tone,
            onTap: () => context.push(
              '${AppRoutes.adminProductRequestDetail}?id=${request.id}',
            ),
          ),
      ],
    );
  }
}
