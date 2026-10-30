part of 'admin_decision_bloc.dart';

sealed class AdminDecisionEvent extends Equatable {
  const AdminDecisionEvent();

  @override
  List<Object?> get props => [];
}

final class AdminDecisionOptionSelected extends AdminDecisionEvent {
  const AdminDecisionOptionSelected(this.index);

  final int index;

  @override
  List<Object?> get props => [index];
}

final class AdminDecisionReasonChanged extends AdminDecisionEvent {
  const AdminDecisionReasonChanged(this.reason);

  final String reason;

  @override
  List<Object?> get props => [reason];
}
