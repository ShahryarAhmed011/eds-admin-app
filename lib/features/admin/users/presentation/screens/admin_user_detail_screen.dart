import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/core.dart';
import '../../../../../core/di/injection.dart';
import '../../../common/admin_common.dart';
import '../../domain/entities/admin_user.dart';
import '../bloc/admin_user_detail_bloc.dart';
import '../widgets/admin_user_labels.dart';
import '../widgets/user_access_sheet.dart';

class AdminUserDetailScreen extends StatelessWidget {
  const AdminUserDetailScreen({super.key, required this.userId});

  final String userId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          sl<AdminUserDetailBloc>()..add(AdminUserDetailRequested(userId)),
      child: _AdminUserDetailView(userId: userId),
    );
  }
}

class _AdminUserDetailView extends StatelessWidget {
  const _AdminUserDetailView({required this.userId});

  final String userId;

  Future<void> _openSheet(
    BuildContext context,
    AdminUserDetailLoaded state,
  ) async {
    final bloc = context.read<AdminUserDetailBloc>();
    final choice = await showUserAccessSheet(
      context,
      user: state.user,
      preset: state.draft?.action,
      initialReason: state.draft?.reason,
    );
    if (choice == null) return;
    bloc.add(
      AdminUserAccessDecisionSubmitted(
        action: choice.action,
        reason: choice.reason,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AdminUserDetailBloc, AdminUserDetailState>(
      listenWhen: (previous, current) =>
          current is AdminUserDetailLoaded &&
          (current.lastAction != null || current.errorMessage != null),
      listener: (context, state) {
        final loaded = state as AdminUserDetailLoaded;
        final toast = EdsToast.of(context);
        if (loaded.errorMessage != null) {
          final ref = loaded.errorReference;
          toast.show(
            ref == null
                ? loaded.errorMessage!
                : '${loaded.errorMessage!} (Ref: $ref)',
            kind: EdsToastKind.error,
          );
        } else if (loaded.lastAction != null) {
          toast.show(
            '${loaded.user.name} is now '
            '${loaded.user.badgeLabel.toLowerCase()} '
            '· Saved in the audit log',
            kind: EdsToastKind.success,
          );
        }
      },
      builder: (context, state) {
        final loaded = state is AdminUserDetailLoaded ? state : null;
        return EdsScaffold(
          title: 'User review',
          bottomNav: const EdsBottomNav(
            items: RoleNavs.admin,
            currentIndex: AdminTab.users,
          ),
          bottomAction: loaded == null
              ? null
              : EdsButton.primary(
                  label: 'Manage account access',
                  isLoading: loaded.isSubmitting,
                  onPressed: () => _openSheet(context, loaded),
                ),
          body: switch (state) {
            AdminUserDetailLoading() => const EdsLoadingView(),
            AdminUserDetailFailure(:final message, :final reference) =>
              EdsErrorView(
                message: message,
                reference: reference,
                onRetry: () => context.read<AdminUserDetailBloc>().add(
                  AdminUserDetailRequested(userId),
                ),
              ),
            AdminUserDetailLoaded(:final user) => _UserContent(user),
          },
        );
      },
    );
  }
}

class _UserContent extends StatelessWidget {
  const _UserContent(this.user);

  final AdminUser user;

  @override
  Widget build(BuildContext context) {
    final shop = user.shop;
    final joined = user.createdAt;
    final verified = user.identityVerifiedAt;
    final signIn = user.lastSignInAt;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        EdsProfileCard(
          name: user.name,
          subtitle: [
            user.reference,
            user.role.label,
            if (joined != null) 'Joined ${AdminFormat.dayMonth(joined)}',
          ].join(' · '),
          badge: user.badgeLabel,
          badgeTone: user.badgeTone,
          details: [user.phone ?? user.email, ?user.location],
        ),
        if (user.alertTitle != null) ...[
          AppSpacing.gapLg,
          EdsBanner(
            title: user.alertTitle!,
            message: user.alertMessage,
            tone: EdsTone.danger,
          ),
        ],
        AppSpacing.gapLg,
        EdsGroupCard(
          header: Text('Account context', style: AppTextStyles.sectionTitle),
          children: [
            if (shop != null)
              AdminRecordTile(
                title: shop.name,
                subtitle: [
                  shop.id,
                  if (shop.statusLabel.isNotEmpty) shop.statusLabel,
                ].join(' · '),
                showChevron: true,
                onTap: () => context.push(
                  '${AppRoutes.adminShopDetail}?id='
                  '${Uri.encodeComponent(shop.id)}',
                ),
              ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.sm,
                AppSpacing.lg,
                AppSpacing.md,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (user.phone != null) ...[
                    Text(user.email, style: AppTextStyles.bodyLarge),
                    AppSpacing.gapMd,
                  ],
                  Text(
                    verified != null
                        ? 'Identity verified · ${AdminFormat.date(verified)}'
                        : 'Onboarding · '
                              '${AdminFormat.humanize(user.onboardingStatus)}',
                    style: AppTextStyles.bodyLarge,
                  ),
                  if (signIn != null) ...[
                    AppSpacing.gapMd,
                    Text(
                      'Last sign in · ${AdminFormat.dateTime(signIn)}',
                      style: AppTextStyles.bodyLarge,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
        AppSpacing.gapLg,
        Text(
          'No full CNIC is available in user records. Access changes are '
          'logged and communicated to the user.',
          style: AppTextStyles.bodySecondary,
        ),
      ],
    );
  }
}
