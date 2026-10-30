part of 'admin_kyc_detail_bloc.dart';

sealed class AdminKycDetailEvent extends Equatable {
  const AdminKycDetailEvent();

  @override
  List<Object?> get props => [];
}

final class AdminKycDetailRequested extends AdminKycDetailEvent {
  const AdminKycDetailRequested(this.id);

  final String id;

  @override
  List<Object?> get props => [id];
}

final class AdminKycDecisionSubmitted extends AdminKycDetailEvent {
  const AdminKycDecisionSubmitted({
    required this.decision,
    required this.reason,
  });

  final KycDecision decision;
  final String reason;

  @override
  List<Object?> get props => [decision, reason];
}
