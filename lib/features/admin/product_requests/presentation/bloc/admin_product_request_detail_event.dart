part of 'admin_product_request_detail_bloc.dart';

sealed class AdminProductRequestDetailEvent extends Equatable {
  const AdminProductRequestDetailEvent();

  @override
  List<Object?> get props => [];
}

final class AdminProductRequestDetailRequested
    extends AdminProductRequestDetailEvent {
  const AdminProductRequestDetailRequested(this.id);

  final String id;

  @override
  List<Object?> get props => [id];
}

final class AdminProductRequestDecisionSubmitted
    extends AdminProductRequestDetailEvent {
  const AdminProductRequestDecisionSubmitted({
    required this.decision,
    required this.reason,
  });

  final ProductRequestDecision decision;
  final String reason;

  @override
  List<Object?> get props => [decision, reason];
}
