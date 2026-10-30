import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/core.dart';
import '../../../../../core/di/injection.dart';
import '../../domain/entities/admin_catalogue_variant.dart';
import '../bloc/admin_catalogue_detail_bloc.dart';
import '../widgets/admin_fact_card.dart';
import '../widgets/admin_product_summary_card.dart';
import '../widgets/catalogue_variant_action_sheet.dart';
import '../widgets/catalogue_variant_labels.dart';

class AdminCatalogueDetailScreen extends StatelessWidget {
  const AdminCatalogueDetailScreen({super.key, required this.variantId});

  final String variantId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          sl<AdminCatalogueDetailBloc>()
            ..add(AdminCatalogueDetailRequested(variantId)),
      child: _AdminCatalogueDetailView(variantId: variantId),
    );
  }
}

class _AdminCatalogueDetailView extends StatelessWidget {
  const _AdminCatalogueDetailView({required this.variantId});

  final String variantId;

  Future<void> _openSheet(
    BuildContext context,
    CatalogueVariantDetail variant,
  ) async {
    final bloc = context.read<AdminCatalogueDetailBloc>();
    final choice = await showCatalogueVariantActionSheet(
      context,
      variant: variant,
    );
    if (choice == null) return;
    bloc.add(
      AdminCatalogueVariantActionSubmitted(
        action: choice.action,
        reason: choice.reason,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AdminCatalogueDetailBloc, AdminCatalogueDetailState>(
      listenWhen: (previous, current) =>
          current is AdminCatalogueDetailLoaded &&
          (current.lastAction != null || current.actionError != null),
      listener: (context, state) {
        final loaded = state as AdminCatalogueDetailLoaded;
        if (loaded.actionError != null) {
          EdsToast.of(
            context,
          ).show(loaded.actionError!, kind: EdsToastKind.error);
        } else if (loaded.lastAction != null) {
          final summary = loaded.variant.summary;
          EdsToast.of(context).show(
            '${summary.skuCode} is now ${summary.badgeLabel.toLowerCase()} '
            '· Saved in the audit log',
            kind: EdsToastKind.success,
          );
        }
      },
      builder: (context, state) {
        final loaded = state is AdminCatalogueDetailLoaded ? state : null;
        return EdsScaffold(
          title: 'Variant review',
          bottomNav: const EdsBottomNav(
            items: RoleNavs.admin,
            currentIndex: AdminTab.catalogue,
          ),
          bottomAction: loaded == null
              ? null
              : EdsButton.primary(
                  label: 'Manage variant',
                  isLoading: loaded.isSubmitting,
                  onPressed: () => _openSheet(context, loaded.variant),
                ),
          body: switch (state) {
            AdminCatalogueDetailLoading() => const EdsLoadingView(),
            AdminCatalogueDetailFailure(:final message, :final reference) =>
              EdsErrorView(
                message: message,
                reference: reference,
                onRetry: () => context.read<AdminCatalogueDetailBloc>().add(
                  AdminCatalogueDetailRequested(variantId),
                ),
              ),
            AdminCatalogueDetailLoaded(:final variant) => _VariantContent(
              variant,
            ),
          },
        );
      },
    );
  }
}

class _VariantContent extends StatelessWidget {
  const _VariantContent(this.variant);

  final CatalogueVariantDetail variant;

  @override
  Widget build(BuildContext context) {
    final summary = variant.summary;
    final price = variant.marketPrice;
    final (min, max) = (variant.priceMin, variant.priceMax);
    final listings = [
      if (variant.linkedListings != null)
        '${variant.linkedListings} linked shop listings',
      if (min != null && max != null)
        'Price range ${min.format()}–${max.format(symbol: '').trim()}',
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AdminProductSummaryCard(
          name: summary.name,
          subtitle: variant.description ?? summary.packLabel,
          highlight: price == null
              ? 'No market price yet'
              : 'Market median ${price.format()}',
          badge: summary.badgeLabel,
          badgeTone: summary.badgeTone,
        ),
        AppSpacing.gapLg,
        AdminFactCard(
          largeTitle: true,
          title: '${summary.skuCode} · ${summary.status.label} variant',
          lines: [
            if (summary.category != null) 'Category: ${summary.category}',
            if (variant.barcode != null) 'Barcode: ${variant.barcode}',
            [
              'Pack size: ${summary.packLabel}',
              if (variant.unit != null) 'Unit: ${variant.unit}',
            ].join(' · '),
            if (variant.sourceLabel != null) 'Source: ${variant.sourceLabel}',
            if (listings.isNotEmpty) listings.join(' · '),
          ],
        ),
        if (variant.reviewTitle != null) ...[
          AppSpacing.gapLg,
          EdsBanner(
            title: variant.reviewTitle!,
            message: variant.reviewMessage,
            tone: EdsTone.warning,
          ),
        ],
        if (variant.lastEditedLabel != null) ...[
          AppSpacing.gapLg,
          Text(variant.lastEditedLabel!, style: AppTextStyles.bodySecondary),
        ],
      ],
    );
  }
}
