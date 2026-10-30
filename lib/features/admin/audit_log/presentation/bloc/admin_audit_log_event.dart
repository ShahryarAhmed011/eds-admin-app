part of 'admin_audit_log_bloc.dart';

sealed class AdminAuditLogEvent extends Equatable {
  const AdminAuditLogEvent();

  @override
  List<Object?> get props => [];
}

final class AdminAuditLogRequested extends AdminAuditLogEvent {
  const AdminAuditLogRequested();
}

final class AdminAuditLogTabChanged extends AdminAuditLogEvent {
  const AdminAuditLogTabChanged(this.tab);

  final AuditLogTab tab;

  @override
  List<Object?> get props => [tab];
}

final class AdminAuditLogSearchChanged extends AdminAuditLogEvent {
  const AdminAuditLogSearchChanged(this.query);

  final String query;

  @override
  List<Object?> get props => [query];
}
