import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/core.dart';
import '../../../../../core/di/injection.dart';
import '../../../common/admin_common.dart';
import '../bloc/admin_kyc_list_bloc.dart';
import '../widgets/kyc_labels.dart';

class KycReviewListScreen extends StatelessWidget {
  const KycReviewListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<AdminKycListBloc>()..add(const AdminKycListRequested()),
      child: const _KycReviewListView(),
    );
  }
}

class _KycReviewListView extends StatelessWidget {
  const _KycReviewListView();

  @override
  Widget build(BuildContext context) {
    return EdsScaffold(
      title: 'KYC reviews',
      bottomNav: const EdsBottomNav(
        items: RoleNavs.admin,
        currentIndex: AdminTab.queues,
      ),
      body: BlocBuilder<AdminKycListBloc, AdminKycListState>(
        builder: (context, state) => switch (state) {
          AdminKycListLoading() => const EdsLoadingView(),
          AdminKycListFailure(:final message, :final reference) => EdsErrorView(
            message: message,
            reference: reference,
            onRetry: () => context.read<AdminKycListBloc>().add(
              const AdminKycListRequested(),
            ),
          ),
          final AdminKycListLoaded loaded => _KycListContent(loaded),
        },
      ),
    );
  }
}

class _KycListContent extends StatelessWidget {
  const _KycListContent(this.state);

  final AdminKycListLoaded state;

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<AdminKycListBloc>();
    final now = DateTime.now();
    final items = state.visibleItems;
    final tabCount = state.countFor(state.tab);
    return AdminFilteredList(
      searchHint: 'Search applicant or review ID',
      onSearchChanged: (q) => bloc.add(AdminKycListSearchChanged(q)),
      tabLabels: [
        'All · ${state.countFor(KycListTab.all)}',
        'Retailers · ${state.countFor(KycListTab.retailers)}',
        'Riders · ${state.countFor(KycListTab.riders)}',
      ],
      selectedTab: state.tab.index,
      onTabChanged: (i) =>
          bloc.add(AdminKycListTabChanged(KycListTab.values[i])),
      title: '$tabCount awaiting review',
      subtitle: 'Oldest first · Showing ${items.length} of $tabCount',
      emptyMessage: state.query.trim().isEmpty
          ? 'No identity reviews are waiting.'
          : 'No applicant matches your search.',
      footer: const EdsBanner(
        title: 'Privacy by default',
        message:
            'Only the last four CNIC digits are available to Admin. '
            'Full identity numbers are never shown.',
        tone: EdsTone.neutral,
      ),
      children: [
        for (final item in items)
          AdminRecordTile(
            title: item.name,
            subtitle: [
              item.reference,
              item.role.label,
              ?item.waitingLabel(now),
            ].join(' · '),
            badge: item.badgeLabel(now),
            badgeTone: item.badgeTone(now),
            onTap: () async {
              await context.push(
                '${AppRoutes.adminKycApplicantDetail}?id=${item.id}',
              );
              // A decision removes the row from the pending queue.
              bloc.add(const AdminKycListRequested());
            },
          ),
      ],
    );
  }
}
