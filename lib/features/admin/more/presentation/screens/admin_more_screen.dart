import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/core.dart';
import '../../../../../core/di/injection.dart';
import '../../domain/entities/admin_profile.dart';
import '../bloc/admin_more_bloc.dart';

class AdminMoreScreen extends StatelessWidget {
  const AdminMoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<AdminMoreBloc>()..add(const AdminMoreRequested()),
      child: const _AdminMoreView(),
    );
  }
}

class _AdminMoreView extends StatelessWidget {
  const _AdminMoreView();

  @override
  Widget build(BuildContext context) {
    return EdsScaffold(
      title: 'Operations & settings',
      bottomNav: const EdsBottomNav(
        items: RoleNavs.admin,
        currentIndex: AdminTab.more,
      ),
      // After sign-out the auth guard moves the user to the role picker.
      body: BlocBuilder<AdminMoreBloc, AdminMoreState>(
        builder: (context, state) => switch (state) {
          AdminMoreLoading() || AdminMoreSignedOut() => const EdsLoadingView(),
          AdminMoreFailure(:final message, :final reference) => EdsErrorView(
            message: message,
            reference: reference,
            onRetry: () =>
                context.read<AdminMoreBloc>().add(const AdminMoreRequested()),
          ),
          AdminMoreLoaded(:final profile, :final isSigningOut) => _MoreContent(
            profile,
            isSigningOut: isSigningOut,
          ),
        },
      ),
    );
  }
}

class _MoreContent extends StatelessWidget {
  const _MoreContent(this.profile, {required this.isSigningOut});

  final AdminProfile profile;
  final bool isSigningOut;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        EdsProfileCard(
          name: profile.fullName,
          subtitle: [
            if (profile.role == AppRole.admin)
              'Operations Admin'
            else
              profile.role.label,
            ?profile.city,
          ].join(' · '),
          badge: profile.role.label,
          details: [profile.phone ?? profile.email],
        ),
        AppSpacing.gapLg,
        EdsGroupCard(
          children: [
            _MoreTile(
              title: 'Product requests',
              subtitle: switch (profile.pendingProductRequests) {
                null => 'New brands and pack sizes',
                1 => '1 request awaiting review',
                final n => '$n requests awaiting review',
              },
              icon: Icons.assignment_outlined,
              route: AppRoutes.adminProductRequests,
            ),
            const _MoreTile(
              title: 'Catalogue scraper',
              subtitle: 'Sources, progress and SKU imports',
              icon: Icons.crop_square,
              route: AppRoutes.adminScraperDashboard,
            ),
            const _MoreTile(
              title: 'Serviceable areas',
              subtitle: 'Town and area coverage controls',
              icon: Icons.location_on_outlined,
              route: AppRoutes.adminServiceableAreas,
            ),
            const _MoreTile(
              title: 'Audit log',
              subtitle: 'Decisions, reasons and actors',
              icon: Icons.history,
              route: AppRoutes.adminAuditLog,
            ),
          ],
        ),
        AppSpacing.gapLg,
        const EdsBanner(
          title: 'Privileged access',
          message:
              'Only act on the areas and records assigned to you. '
              'Every change is traceable.',
          tone: EdsTone.neutral,
        ),
        AppSpacing.gapLg,
        EdsButton.secondary(
          label: 'Sign out',
          isLoading: isSigningOut,
          onPressed: () => context.read<AdminMoreBloc>().add(
            const AdminMoreSignOutRequested(),
          ),
        ),
      ],
    );
  }
}

class _MoreTile extends StatelessWidget {
  const _MoreTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.route,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final String route;

  @override
  Widget build(BuildContext context) {
    return EdsListTile(
      title: title,
      titleStyle: AppTextStyles.itemTitleLarge,
      subtitle: subtitle,
      trailing: Icon(icon, color: AppColors.ink),
      onTap: () => context.push(route),
    );
  }
}
