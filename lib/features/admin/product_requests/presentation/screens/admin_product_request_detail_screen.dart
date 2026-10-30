import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/core.dart';
import '../../../../../core/di/injection.dart';
import '../../../catalogue/presentation/widgets/admin_fact_card.dart';
import '../../../catalogue/presentation/widgets/admin_product_summary_card.dart';
import '../../../audit_log/presentation/widgets/admin_time_format.dart';
import '../../../common/admin_common.dart';
import '../../domain/entities/admin_product_request.dart';
import '../bloc/admin_product_request_detail_bloc.dart';
import '../widgets/product_request_decision_sheet.dart';
import '../widgets/product_request_labels.dart';

class AdminProductRequestDetailScreen extends StatelessWidget {
  const AdminProductRequestDetailScreen({super.key, required this.requestId});

  final String requestId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          sl<AdminProductRequestDetailBloc>()
            ..add(AdminProductRequestDetailRequested(requestId)),
      child: _AdminProductRequestDetailView(requestId: requestId),
    );
  }
}

class _AdminProductRequestDetailView extends StatelessWidget {
  const _AdminProductRequestDetailView({required this.requestId});

  final String requestId;

  Future<void> _openSheet(
    BuildContext context,
    ProductRequestDetail request,
  ) async {
    final bloc = context.read<AdminProductRequestDetailBloc>();
    final choice = await showProductRequestDecisionSheet(
      context,
      request: request,
    );
    if (choice == null) return;
    bloc.add(
      AdminProductRequestDecisionSubmitted(
        decision: choice.decision,
        reason: choice.reason,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<
      AdminProductRequestDetailBloc,
      AdminProductRequestDetailState
    >(
      listenWhen: (previous, current) =>
          current is AdminProductRequestDetailLoaded &&
          (current.lastDecision != null || current.actionError != null),
      listener: (context, state) {
        final loaded = state as AdminProductRequestDetailLoaded;
        final summary = loaded.request.summary;
        if (loaded.actionError != null) {
          EdsToast.of(
            context,
          ).show(loaded.actionError!, kind: EdsToastKind.error);
        } else if (loaded.lastDecision != null) {
          EdsToast.of(context).show(
            '${summary.code} ${summary.status.label.toLowerCase()} '
            '· Retailer notified',
            kind: EdsToastKind.success,
          );
        }
      },
      builder: (context, state) {
        final loaded = state is AdminProductRequestDetailLoaded ? state : null;
        final pending =
            loaded?.request.summary.status == ProductRequestStatus.pending;
        return EdsScaffold(
          title: 'Review request',
          bottomNav: const EdsBottomNav(
            items: RoleNavs.admin,
            currentIndex: AdminTab.queues,
          ),
          bottomAction: loaded == null || !pending
              ? null
              : EdsButton.primary(
                  label: 'Approve or reject request',
                  isLoading: loaded.isSubmitting,
                  onPressed: () => _openSheet(context, loaded.request),
                ),
          body: switch (state) {
            AdminProductRequestDetailLoading() => const EdsLoadingView(),
            AdminProductRequestDetailFailure(
              :final message,
              :final reference,
            ) =>
              EdsErrorView(
                message: message,
                reference: reference,
                onRetry: () => context
                    .read<AdminProductRequestDetailBloc>()
                    .add(AdminProductRequestDetailRequested(requestId)),
              ),
            AdminProductRequestDetailLoaded(:final request) => _RequestContent(
              request,
            ),
          },
        );
      },
    );
  }
}

class _RequestContent extends StatelessWidget {
  const _RequestContent(this.request);

  final ProductRequestDetail request;

  @override
  Widget build(BuildContext context) {
    final summary = request.summary;
    final price = request.suggestedPrice;
    final check = request.duplicateCheck;
    final submittedAt = request.submittedAt;
    final category =
        request.category ??
        (request.categoryId == null ? null : '#${request.categoryId}');
    final shopContact = [?request.shopOwner, ?request.shopPhone];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AdminProductSummaryCard(
          name: summary.productName,
          subtitle: [
            ?request.brand,
            ?request.description,
            if (summary.packLabel.isNotEmpty) summary.packLabel,
          ].join(' · '),
          highlight: price == null
              ? 'No price submitted'
              : 'Suggested price ${price.format()}',
          badge: summary.status.label,
          badgeTone: summary.status.tone,
        ),
        AppSpacing.gapLg,
        AdminFactCard(
          title: submittedAt == null
              ? summary.code
              : '${summary.code} · Submitted '
                    '${formatAdminDayTime(submittedAt)}',
          lines: [
            if (category != null) 'Category: $category',
            if (request.barcode != null) 'Barcode: ${request.barcode}',
            if (request.packDetail != null) 'Pack: ${request.packDetail}',
            if (request.rejectionReason != null)
              'Rejection reason: ${request.rejectionReason}',
          ],
          footnote: request.retailerNote == null
              ? null
              : 'Retailer note: ${request.retailerNote}',
        ),
        AppSpacing.gapLg,
        EdsGroupCard(
          children: [
            AdminRecordTile(
              title: summary.shopLabel,
              subtitle: shopContact.isEmpty
                  ? 'Shop #${summary.shopId}'
                  : shopContact.join(' · '),
              showChevron: true,
              onTap: () => context.push(
                '${AppRoutes.adminShopDetail}?id=${summary.shopId}',
              ),
            ),
          ],
        ),
        if (check != null) ...[
          AppSpacing.gapLg,
          EdsBanner(
            title: check.title,
            message: check.message,
            tone: check.isDuplicate ? EdsTone.danger : EdsTone.success,
          ),
        ],
      ],
    );
  }
}
