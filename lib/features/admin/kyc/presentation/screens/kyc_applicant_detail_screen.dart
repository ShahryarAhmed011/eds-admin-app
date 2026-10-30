import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/core.dart';
import '../../../../../core/di/injection.dart';
import '../../../common/admin_common.dart';
import '../../domain/entities/kyc_applicant.dart';
import '../bloc/admin_kyc_detail_bloc.dart';
import '../widgets/kyc_decision_sheet.dart';
import '../widgets/kyc_documents.dart';
import '../widgets/kyc_labels.dart';

class KycApplicantDetailScreen extends StatelessWidget {
  const KycApplicantDetailScreen({super.key, required this.applicationId});

  /// KYC record id (`GET /admin/kyc` item `id`).
  final String applicationId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          sl<AdminKycDetailBloc>()..add(AdminKycDetailRequested(applicationId)),
      child: _KycApplicantDetailView(applicationId: applicationId),
    );
  }
}

class _KycApplicantDetailView extends StatelessWidget {
  const _KycApplicantDetailView({required this.applicationId});

  static const _checklist = [
    'Name matches application',
    'Both sides clear and unexpired',
    'No duplicate identity flags',
  ];

  final String applicationId;

  /// Confirms [decision] (with an optional reason) in the decision sheet,
  /// then submits it.
  Future<void> _openSheet(
    BuildContext context,
    AdminKycDetailLoaded state,
    KycDecision decision,
  ) async {
    final bloc = context.read<AdminKycDetailBloc>();
    final choice = await showKycDecisionSheet(
      context,
      applicant: state.applicant,
      preset: decision,
      initialReason: state.draft?.reason,
    );
    if (choice == null) return;
    bloc.add(
      AdminKycDecisionSubmitted(
        decision: choice.decision,
        reason: choice.reason,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AdminKycDetailBloc, AdminKycDetailState>(
      listenWhen: (previous, current) =>
          current is AdminKycDetailLoaded &&
          (current.justDecided || current.errorMessage != null),
      listener: (context, state) {
        final loaded = state as AdminKycDetailLoaded;
        final toast = EdsToast.of(context);
        if (loaded.errorMessage != null) {
          final ref = loaded.errorReference;
          toast.show(
            ref == null
                ? loaded.errorMessage!
                : '${loaded.errorMessage!} (Ref: $ref)',
            kind: EdsToastKind.error,
          );
        } else if (loaded.justDecided) {
          final a = loaded.applicant;
          toast.show(
            '${a.reference} ${a.badgeLabel(DateTime.now()).toLowerCase()}'
            ' · ${a.name} has been notified',
            kind: EdsToastKind.success,
          );
        }
      },
      builder: (context, state) {
        final loaded = state is AdminKycDetailLoaded ? state : null;
        return EdsScaffold(
          title: 'Review identity',
          bottomNav: const EdsBottomNav(
            items: RoleNavs.admin,
            currentIndex: AdminTab.queues,
          ),
          bottomAction: loaded == null || loaded.applicant.isDecided
              ? null
              : Row(
                  children: [
                    Expanded(
                      child: EdsButton.secondary(
                        label: 'Reject',
                        icon: Icons.close,
                        onPressed: loaded.isSubmitting
                            ? null
                            : () => _openSheet(
                                context,
                                loaded,
                                KycDecision.reject,
                              ),
                      ),
                    ),
                    AppSpacing.gapMd,
                    Expanded(
                      child: EdsButton.primary(
                        label: 'Approve',
                        icon: Icons.check,
                        isLoading: loaded.isSubmitting,
                        onPressed: () =>
                            _openSheet(context, loaded, KycDecision.approve),
                      ),
                    ),
                  ],
                ),
          body: switch (state) {
            AdminKycDetailLoading() => const EdsLoadingView(),
            AdminKycDetailFailure(:final message, :final reference) =>
              EdsErrorView(
                message: message,
                reference: reference,
                onRetry: () => context.read<AdminKycDetailBloc>().add(
                  AdminKycDetailRequested(applicationId),
                ),
              ),
            AdminKycDetailLoaded(:final applicant) => _ApplicantContent(
              applicant,
              checklist: _checklist,
            ),
          },
        );
      },
    );
  }
}

class _ApplicantContent extends StatelessWidget {
  const _ApplicantContent(this.applicant, {required this.checklist});

  final KycApplicant applicant;
  final List<String> checklist;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final expiry = applicant.expiryDate;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        EdsProfileCard(
          name: applicant.name,
          subtitle: [
            applicant.reference,
            applicant.role.label,
            ?applicant.submittedLabel(now),
          ].join(' · '),
          badge: applicant.badgeLabel(now),
          badgeTone: applicant.badgeTone(now),
          details: [
            ?applicant.shopLabel,
            ?applicant.phone,
            'CNIC last 4 digits: ${applicant.cnicLast4}',
            if (expiry != null)
              '${expiry.isBefore(now) ? 'Expired' : 'Expires'} '
                  '${AdminFormat.date(expiry)}',
          ],
        ),
        AppSpacing.gapLg,
        KycDocuments(applicant: applicant),
        AppSpacing.gapLg,
        EdsCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Review checklist', style: AppTextStyles.sectionTitle),
              for (final item in checklist) ...[
                AppSpacing.gapMd,
                Text('•  $item', style: AppTextStyles.bodyLarge),
              ],
            ],
          ),
        ),
        AppSpacing.gapLg,
        const EdsBanner(
          title: 'Review restricted identity data',
          message:
              'Do not request or record a full CNIC number in the reason '
              'field.',
          tone: EdsTone.neutral,
        ),
      ],
    );
  }
}
