import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/core.dart';
import '../../../../../core/di/injection.dart';
import '../../../common/admin_common.dart';
import '../../domain/entities/admin_queues.dart';
import '../bloc/admin_queues_bloc.dart';

class AdminQueuesScreen extends StatelessWidget {
  const AdminQueuesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<AdminQueuesBloc>()..add(const AdminQueuesRequested()),
      child: const _AdminQueuesView(),
    );
  }
}

class _AdminQueuesView extends StatelessWidget {
  const _AdminQueuesView();

  @override
  Widget build(BuildContext context) {
    return EdsScaffold(
      title: 'Review queues',
      bottomNav: const EdsBottomNav(
        items: RoleNavs.admin,
        currentIndex: AdminTab.queues,
      ),
      body: BlocBuilder<AdminQueuesBloc, AdminQueuesState>(
        builder: (context, state) => switch (state) {
          AdminQueuesLoading() => const EdsLoadingView(),
          AdminQueuesFailure(:final message, :final reference) => EdsErrorView(
            message: message,
            reference: reference,
            onRetry: () => context.read<AdminQueuesBloc>().add(
              const AdminQueuesRequested(),
            ),
          ),
          AdminQueuesLoaded(:final queues) => _QueuesContent(queues),
        },
      ),
    );
  }
}

class _QueuesContent extends StatelessWidget {
  const _QueuesContent(this.data);

  final AdminQueues data;

  @override
  Widget build(BuildContext context) {
    final refreshed = data.refreshedAt;
    final total = data.totalPending;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        EdsSectionHeader(
          title: data.region ?? 'Operations overview',
          subtitle:
              '${AdminFormat.date(refreshed)} · '
              'Refreshed ${AdminFormat.time(refreshed)}',
        ),
        AppSpacing.gapLg,
        EdsBanner(
          title: total == 1
              ? '1 item needs a decision'
              : '$total items need a decision',
          message: 'Prioritise identity reviews older than 24 hours.',
          tone: total == 0 ? EdsTone.success : EdsTone.warning,
        ),
        AppSpacing.gapLg,
        EdsGroupCard(
          children: [
            for (final queue in data.queues)
              EdsListTile(
                title: _title(queue.type),
                titleStyle: AppTextStyles.itemTitleLarge,
                subtitle: _summary(queue),
                trailing: queue.count == null
                    ? null
                    : EdsCountBadge(queue.count!, tone: _tone(queue.type)),
                showChevron: queue.count == null,
                onTap: () async {
                  await context.push(_route(queue.type));
                  if (context.mounted) {
                    context.read<AdminQueuesBloc>().add(
                      const AdminQueuesRequested(),
                    );
                  }
                },
              ),
          ],
        ),
        if (data.unknownCount > 0) ...[
          AppSpacing.gapMd,
          Row(
            children: [
              Expanded(
                child: Text(
                  'Some counts could not be loaded.',
                  style: AppTextStyles.caption,
                ),
              ),
              EdsButton.text(
                label: 'Refresh',
                onPressed: () => context.read<AdminQueuesBloc>().add(
                  const AdminQueuesRequested(),
                ),
              ),
            ],
          ),
        ],
        AppSpacing.gapLg,
        Text(
          'Every decision requires a reason and is recorded in the audit log.',
          style: AppTextStyles.bodySecondary,
        ),
      ],
    );
  }

  String _title(AdminQueueType type) => switch (type) {
    AdminQueueType.kyc => 'KYC reviews',
    AdminQueueType.shops => 'Shops ready for activation',
    AdminQueueType.users => 'Flagged users',
    AdminQueueType.productRequests => 'Product requests',
    AdminQueueType.catalogueVariants => 'Catalogue variants',
  };

  String _summary(AdminQueue queue) => switch (queue.type) {
    AdminQueueType.kyc => _kycSummary(),
    AdminQueueType.shops => 'Identity approved · Catalogue complete',
    AdminQueueType.users => 'Account and access reviews',
    AdminQueueType.productRequests => 'New brands and pack sizes',
    AdminQueueType.catalogueVariants => 'Duplicate and data-quality checks',
  };

  String _kycSummary() {
    final oldest = data.kycOldestAt;
    final parts = [
      if (data.kycRetailers != null) '${data.kycRetailers} retailers',
      if (data.kycRiders != null) '${data.kycRiders} riders',
      if (oldest != null)
        'Oldest ${AdminFormat.age(oldest, now: data.refreshedAt)}',
    ];
    return parts.isEmpty
        ? 'Retailer and rider identity checks'
        : parts.join(' · ');
  }

  EdsTone _tone(AdminQueueType type) => switch (type) {
    AdminQueueType.shops => EdsTone.success,
    AdminQueueType.users => EdsTone.danger,
    AdminQueueType.kyc ||
    AdminQueueType.productRequests ||
    AdminQueueType.catalogueVariants => EdsTone.warning,
  };

  String _route(AdminQueueType type) => switch (type) {
    AdminQueueType.kyc => AppRoutes.adminKycReviewList,
    AdminQueueType.shops => AppRoutes.adminShops,
    AdminQueueType.users => AppRoutes.adminUsers,
    AdminQueueType.productRequests => AppRoutes.adminProductRequests,
    AdminQueueType.catalogueVariants => AppRoutes.adminCatalogueVariants,
  };
}
