part of 'admin_kyc_detail_bloc.dart';

/// A decision the admin tried to submit; restored into the sheet on failure.
final class KycDecisionDraft extends Equatable {
  const KycDecisionDraft(this.decision, this.reason);

  final KycDecision decision;
  final String reason;

  @override
  List<Object?> get props => [decision, reason];
}

sealed class AdminKycDetailState extends Equatable {
  const AdminKycDetailState();

  @override
  List<Object?> get props => [];
}

final class AdminKycDetailLoading extends AdminKycDetailState {
  const AdminKycDetailLoading();
}

final class AdminKycDetailLoaded extends AdminKycDetailState {
  const AdminKycDetailLoaded(
    this.applicant, {
    this.isSubmitting = false,
    this.justDecided = false,
    this.draft,
    this.errorMessage,
    this.errorReference,
  });

  final KycApplicant applicant;
  final bool isSubmitting;

  /// True on the state emitted right after a successful decision.
  final bool justDecided;

  /// Last attempted decision, kept after a failed submit.
  final KycDecisionDraft? draft;

  /// Set on the state emitted right after a failed submit.
  final String? errorMessage;
  final String? errorReference;

  @override
  List<Object?> get props => [
    applicant,
    isSubmitting,
    justDecided,
    draft,
    errorMessage,
    errorReference,
  ];
}

final class AdminKycDetailFailure extends AdminKycDetailState {
  const AdminKycDetailFailure(this.message, {this.reference});

  final String message;
  final String? reference;

  @override
  List<Object?> get props => [message, reference];
}
