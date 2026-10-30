import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/core.dart';
import '../../../../../core/di/injection.dart';
import '../../../common/admin_common.dart';
import '../bloc/admin_audit_log_bloc.dart';
import '../widgets/admin_time_format.dart';
import '../widgets/audit_entry_tile.dart';

class AdminAuditLogScreen extends StatelessWidget {
  const AdminAuditLogScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          sl<AdminAuditLogBloc>()..add(const AdminAuditLogRequested()),
      child: const _AdminAuditLogView(),
    );
  }
}

class _AdminAuditLogView extends StatelessWidget {
  const _AdminAuditLogView();

  @override
  Widget build(BuildContext context) {
    return EdsScaffold(
      title: 'Audit log',
      bottomNav: const EdsBottomNav(
        items: RoleNavs.admin,
        currentIndex: AdminTab.more,
      ),
      body: BlocBuilder<AdminAuditLogBloc, AdminAuditLogState>(
        builder: (context, state) => switch (state) {
          AdminAuditLogLoading() => const EdsLoadingView(),
          AdminAuditLogFailure(:final message, :final reference) =>
            EdsErrorView(
              message: message,
              reference: reference,
              onRetry: () => context.read<AdminAuditLogBloc>().add(
                const AdminAuditLogRequested(),
              ),
            ),
          final AdminAuditLogLoaded loaded => _AuditLogContent(loaded),
        },
      ),
    );
  }
}

class _AuditLogContent extends StatelessWidget {
  const _AuditLogContent(this.state);

  final AdminAuditLogLoaded state;

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<AdminAuditLogBloc>();
    final scope = switch (state.tab) {
      AuditLogTab.today => formatAdminDate(state.page.asOf),
      AuditLogTab.allActions => 'All dates',
      AuditLogTab.allAdmins => 'Grouped by admin',
    };
    return AdminFilteredList(
      searchHint: 'Search actor, entity or action',
      onSearchChanged: (q) => bloc.add(AdminAuditLogSearchChanged(q)),
      tabLabels: const ['Today', 'All actions', 'All admins'],
      selectedTab: state.tab.index,
      onTabChanged: (i) =>
          bloc.add(AdminAuditLogTabChanged(AuditLogTab.values[i])),
      title: 'Immutable activity record',
      subtitle: '$scope · Pakistan Standard Time',
      emptyMessage: 'No activity recorded for this filter.',
      footer: Text(
        'Sensitive identity numbers are not stored in action reasons or '
        'audit entries.',
        style: AppTextStyles.bodySecondary,
      ),
      children: [
        for (final entry in state.visibleEntries)
          AuditEntryTile(entry: entry, showDate: !state.isToday(entry)),
      ],
    );
  }
}
