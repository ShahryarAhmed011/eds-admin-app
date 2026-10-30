import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/core.dart';
import '../../../../../core/di/injection.dart';
import '../../../common/admin_common.dart';
import '../../domain/repository/admin_users_repository.dart';
import '../bloc/admin_users_list_bloc.dart';
import '../widgets/admin_user_labels.dart';

class AdminUsersListScreen extends StatelessWidget {
  const AdminUsersListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          sl<AdminUsersListBloc>()..add(const AdminUsersListRequested()),
      child: const _AdminUsersListView(),
    );
  }
}

class _AdminUsersListView extends StatelessWidget {
  const _AdminUsersListView();

  @override
  Widget build(BuildContext context) {
    return EdsScaffold(
      title: 'Manage users',
      bottomNav: const EdsBottomNav(
        items: RoleNavs.admin,
        currentIndex: AdminTab.users,
      ),
      body: BlocBuilder<AdminUsersListBloc, AdminUsersListState>(
        builder: (context, state) => switch (state) {
          AdminUsersListLoading() => const EdsLoadingView(),
          AdminUsersListFailure(:final message, :final reference) =>
            EdsErrorView(
              message: message,
              reference: reference,
              onRetry: () => context.read<AdminUsersListBloc>().add(
                const AdminUsersListRequested(),
              ),
            ),
          final AdminUsersListLoaded loaded => _UsersListContent(loaded),
        },
      ),
    );
  }
}

class _UsersListContent extends StatelessWidget {
  const _UsersListContent(this.state);

  final AdminUsersListLoaded state;

  static String _count(int? n) => switch (n) {
    null => '',
    >= AdminUsersRepository.pageLimit =>
      ' · ${AdminUsersRepository.pageLimit}+',
    _ => ' · $n',
  };

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<AdminUsersListBloc>();
    final users = state.visibleItems;
    final count = _count(state.countFor(state.tab)).replaceFirst(' · ', '');
    final (title, subtitle) = switch (state.tab) {
      UsersListTab.all => (
        count.isEmpty ? 'All accounts' : '$count accounts',
        'Showing ${users.length} · All roles',
      ),
      UsersListTab.flagged => (
        count.isEmpty ? 'Flagged accounts' : '$count flagged accounts',
        'Access reviews · All roles',
      ),
      UsersListTab.suspended => (
        count.isEmpty ? 'Suspended accounts' : '$count suspended accounts',
        'Restored only after support review',
      ),
    };
    return AdminFilteredList(
      searchHint: 'Search name, +92 phone or ID',
      onSearchChanged: (q) => bloc.add(AdminUsersListSearchChanged(q)),
      tabLabels: [
        'All${_count(state.countFor(UsersListTab.all))}',
        'Flagged${_count(state.countFor(UsersListTab.flagged))}',
        'Suspended${_count(state.countFor(UsersListTab.suspended))}',
      ],
      selectedTab: state.tab.index,
      onTabChanged: (i) =>
          bloc.add(AdminUsersListTabChanged(UsersListTab.values[i])),
      title: title,
      subtitle: subtitle,
      emptyMessage: state.query.trim().isEmpty
          ? 'No accounts in this list.'
          : 'No account matches your search.',
      footer: const EdsBanner(
        title: 'Review before restricting access',
        message:
            'Account actions require a reason. Role and shop status are '
            'reviewed separately.',
        tone: EdsTone.neutral,
      ),
      children: [
        for (final user in users)
          AdminRecordTile(
            title: user.name,
            subtitle: user.listSubtitle,
            badge: user.badgeLabel,
            badgeTone: user.badgeTone,
            onTap: () async {
              await context.push(
                '${AppRoutes.adminUserDetail}?id=${Uri.encodeComponent(user.id)}',
              );
              bloc.add(const AdminUsersListRequested());
            },
          ),
      ],
    );
  }
}
