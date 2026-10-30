import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/core.dart';
import '../../../../../core/di/injection.dart';
import '../../domain/entities/admin_queues.dart';
import '../bloc/admin_queues_bloc.dart';

/// Admin "Home" (first tab): a greeting, what needs a decision, and quick
/// actions — KYC reviews first.
class AdminHomeScreen extends StatelessWidget {
  const AdminHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<AdminQueuesBloc>()..add(const AdminQueuesRequested()),
      child: const _AdminHomeView(),
    );
  }
}

class _AdminHomeView extends StatelessWidget {
  const _AdminHomeView();

  @override
  Widget build(BuildContext context) {
    return EdsScaffold(
      title: 'Home',
      leading: EdsAppBarLeading.brand,
      bottomNav: const EdsBottomNav(
        items: RoleNavs.admin,
        currentIndex: AdminTab.home,
      ),
      scrollable: false,
      padding: EdgeInsets.zero,
      body: BlocBuilder<AdminQueuesBloc, AdminQueuesState>(
        builder: (context, state) => RefreshIndicator(
          color: AppColors.crimson,
          onRefresh: () async =>
              context.read<AdminQueuesBloc>().add(const AdminQueuesRequested()),
          child: ListView(
            padding: AppSpacing.screenPadding,
            children: [
              _Greeting(),
              AppSpacing.gapLg,
              switch (state) {
                AdminQueuesLoaded(:final queues) => _PendingBanner(queues),
                AdminQueuesFailure(:final message) => EdsBanner(
                  title: 'Couldn’t load the counts',
                  message: message,
                  tone: EdsTone.danger,
                ),
                _ => const SizedBox.shrink(),
              },
              AppSpacing.gapXl,
              const EdsSectionHeader(title: 'Quick actions'),
              AppSpacing.gapMd,
              _QuickActions(
                queues: state is AdminQueuesLoaded ? state.queues : null,
                loading: state is AdminQueuesLoading,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Greeting extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final greeting = switch (now.hour) {
      < 12 => 'Good morning',
      < 17 => 'Good afternoon',
      _ => 'Good evening',
    };
    const days = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(greeting, style: AppTextStyles.headline),
        AppSpacing.gapXs,
        Text(
          '${days[now.weekday - 1]}, ${now.day} ${months[now.month - 1]}',
          style: AppTextStyles.bodySecondary,
        ),
      ],
    );
  }
}

class _PendingBanner extends StatelessWidget {
  const _PendingBanner(this.queues);

  final AdminQueues queues;

  @override
  Widget build(BuildContext context) {
    final total = queues.totalPending;
    return EdsBanner(
      title: switch (total) {
        0 => 'All caught up',
        1 => '1 item needs a decision',
        _ => '$total items need a decision',
      },
      message: total == 0
          ? 'Nothing is waiting for a review.'
          : 'Start with identity reviews older than 24 hours.',
      tone: total == 0 ? EdsTone.success : EdsTone.warning,
    );
  }
}

/// Two columns of action boxes; KYC reviews first.
class _QuickActions extends StatelessWidget {
  const _QuickActions({required this.queues, required this.loading});

  final AdminQueues? queues;
  final bool loading;

  int? _count(AdminQueueType type) {
    for (final queue in queues?.queues ?? const <AdminQueue>[]) {
      if (queue.type == type) return queue.count;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final retailers = queues?.kycRetailers;
    final riders = queues?.kycRiders;
    final actions = [
      _Action(
        icon: Icons.verified_user_outlined,
        title: 'KYC Reviews',
        detail: retailers != null && riders != null
            ? '$retailers ${retailers == 1 ? 'store' : 'stores'} · '
                  '$riders ${riders == 1 ? 'rider' : 'riders'}'
            : 'Stores and riders',
        count: _count(AdminQueueType.kyc),
        route: AppRoutes.adminKycReviewList,
      ),
      _Action(
        icon: Icons.add_box_outlined,
        title: 'Product requests',
        detail: 'New products from shops',
        count: _count(AdminQueueType.productRequests),
        route: AppRoutes.adminProductRequests,
      ),
      _Action(
        icon: Icons.layers_outlined,
        title: 'Review queues',
        detail: 'Everything waiting',
        count: queues?.totalPending,
        route: AppRoutes.adminQueues,
      ),
      const _Action(
        icon: Icons.map_outlined,
        title: 'Service areas',
        detail: 'Where EDS delivers',
        route: AppRoutes.adminServiceableAreas,
      ),
      const _Action(
        icon: Icons.cloud_download_outlined,
        title: 'Catalogue scraper',
        detail: 'Import products',
        route: AppRoutes.adminScraperDashboard,
      ),
      const _Action(
        icon: Icons.history,
        title: 'Audit log',
        detail: 'Who changed what',
        route: AppRoutes.adminAuditLog,
      ),
    ];
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: AppSpacing.md,
      crossAxisSpacing: AppSpacing.md,
      childAspectRatio: 1.15,
      children: [
        for (final action in actions)
          _ActionCard(action: action, loadingCount: loading),
      ],
    );
  }
}

class _Action {
  const _Action({
    required this.icon,
    required this.title,
    required this.detail,
    required this.route,
    this.count,
  });

  final IconData icon;
  final String title;
  final String detail;
  final String route;

  /// Items waiting; null when the action has no count (or it's unknown).
  final int? count;
}

class _ActionCard extends StatelessWidget {
  const _ActionCard({required this.action, required this.loadingCount});

  final _Action action;
  final bool loadingCount;

  @override
  Widget build(BuildContext context) {
    final count = action.count;
    return Semantics(
      button: true,
      label: count == null || count == 0
          ? action.title
          : '${action.title}, $count waiting',
      child: Material(
        color: AppColors.white,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.mdAll,
          side: BorderSide(color: AppColors.border),
        ),
        child: InkWell(
          onTap: () => context.push(action.route),
          borderRadius: AppRadius.mdAll,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.primaryTint,
                        borderRadius: AppRadius.smAll,
                      ),
                      child: Icon(action.icon, color: AppColors.crimson),
                    ),
                    const Spacer(),
                    if (count != null && count > 0)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm,
                          vertical: AppSpacing.xxs,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.crimson,
                          borderRadius: AppRadius.pillAll,
                        ),
                        child: Text(
                          '$count',
                          style: AppTextStyles.badge.copyWith(
                            color: AppColors.white,
                          ),
                        ),
                      )
                    else if (loadingCount && action.count == null)
                      const SizedBox.square(
                        dimension: 14,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.crimson,
                        ),
                      ),
                  ],
                ),
                const Spacer(),
                Text(
                  action.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.itemTitleLarge,
                ),
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  action.detail,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.caption,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
