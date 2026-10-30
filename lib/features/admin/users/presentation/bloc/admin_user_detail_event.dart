part of 'admin_user_detail_bloc.dart';

sealed class AdminUserDetailEvent extends Equatable {
  const AdminUserDetailEvent();

  @override
  List<Object?> get props => [];
}

final class AdminUserDetailRequested extends AdminUserDetailEvent {
  const AdminUserDetailRequested(this.id);

  final String id;

  @override
  List<Object?> get props => [id];
}

final class AdminUserAccessDecisionSubmitted extends AdminUserDetailEvent {
  const AdminUserAccessDecisionSubmitted({
    required this.action,
    required this.reason,
  });

  final AdminUserAccessAction action;
  final String reason;

  @override
  List<Object?> get props => [action, reason];
}
