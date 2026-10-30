import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/core.dart';
import '../../../../../core/di/injection.dart';
import '../../../common/admin_common.dart';
import '../../domain/entities/admin_shop.dart';
import '../bloc/admin_shop_detail_bloc.dart';
import '../widgets/admin_shop_labels.dart';
import '../widgets/shop_status_sheet.dart';

class AdminShopDetailScreen extends StatelessWidget {
  const AdminShopDetailScreen({super.key, required this.shopId});

  final String shopId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          sl<AdminShopDetailBloc>()..add(AdminShopDetailRequested(shopId)),
      child: _AdminShopDetailView(shopId: shopId),
    );
  }
}

class _AdminShopDetailView extends StatelessWidget {
  const _AdminShopDetailView({required this.shopId});

  final String shopId;

  Future<void> _openSheet(
    BuildContext context,
    AdminShopDetailLoaded state,
  ) async {
    final bloc = context.read<AdminShopDetailBloc>();
    final choice = await showShopStatusSheet(
      context,
      shop: state.shop,
      preset: state.draft?.action,
      initialReason: state.draft?.reason,
    );
    if (choice == null) return;
    bloc.add(
      AdminShopStatusDecisionSubmitted(
        action: choice.action,
        reason: choice.reason,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AdminShopDetailBloc, AdminShopDetailState>(
      listenWhen: (previous, current) =>
          current is AdminShopDetailLoaded &&
          (current.lastAction != null || current.errorMessage != null),
      listener: (context, state) {
        final loaded = state as AdminShopDetailLoaded;
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
            '${loaded.shop.name} is now '
            '${loaded.shop.badgeLabel.toLowerCase()} '
            '· Saved in the audit log',
            kind: EdsToastKind.success,
          );
        }
      },
      builder: (context, state) {
        final loaded = state is AdminShopDetailLoaded ? state : null;
        return EdsScaffold(
          title: 'Shop review',
          bottomNav: const EdsBottomNav(
            items: RoleNavs.admin,
            currentIndex: AdminTab.shops,
          ),
          bottomAction: loaded == null
              ? null
              : EdsButton.primary(
                  label: 'Manage shop status',
                  isLoading: loaded.isSubmitting,
                  onPressed: () => _openSheet(context, loaded),
                ),
          body: switch (state) {
            AdminShopDetailLoading() => const EdsLoadingView(),
            AdminShopDetailFailure(:final message, :final reference) =>
              EdsErrorView(
                message: message,
                reference: reference,
                onRetry: () => context.read<AdminShopDetailBloc>().add(
                  AdminShopDetailRequested(shopId),
                ),
              ),
            AdminShopDetailLoaded(:final shop) => _ShopContent(shop),
          },
        );
      },
    );
  }
}

class _ShopContent extends StatelessWidget {
  const _ShopContent(this.shop);

  final AdminShop shop;

  @override
  Widget build(BuildContext context) {
    final (bannerTitle, bannerMessage, bannerTone) = shop.visibilityBanner;
    final hours = shop.hoursLabel;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        EdsProfileCard(
          name: shop.name,
          subtitle: '${shop.reference} · ${shop.ownerLabel}',
          badge: shop.badgeLabel,
          badgeTone: shop.badgeTone,
          details: [
            shop.phone ??
                'Category · ${AdminFormat.humanize(shop.categoryCode)}',
          ],
        ),
        AppSpacing.gapLg,
        EdsGroupCard(
          header: Text('Readiness checks', style: AppTextStyles.sectionTitle),
          children: [
            for (final check in shop.readinessChecks)
              EdsListTile(
                title: check.title,
                titleStyle: AppTextStyles.itemTitleLarge,
                subtitle: check.detail,
                trailing: Icon(
                  check.passed
                      ? Icons.check_circle_outline
                      : Icons.error_outline,
                  color: check.passed ? AppColors.mustard : AppColors.ink,
                ),
              ),
          ],
        ),
        if (hours != null) ...[
          AppSpacing.gapLg,
          EdsCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(hours, style: AppTextStyles.itemTitleLarge),
                if (shop.pinLabel != null) ...[
                  AppSpacing.gapMd,
                  Text('Pin: ${shop.pinLabel}', style: AppTextStyles.bodyLarge),
                ],
                if (shop.updatedLabel != null) ...[
                  AppSpacing.gapMd,
                  Text(shop.updatedLabel!, style: AppTextStyles.bodySecondary),
                ],
              ],
            ),
          ),
        ],
        AppSpacing.gapLg,
        EdsBanner(title: bannerTitle, message: bannerMessage, tone: bannerTone),
      ],
    );
  }
}
