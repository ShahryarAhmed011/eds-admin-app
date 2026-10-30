import '../../../../../core/core.dart';
import '../entities/audit_entry.dart';
import '../repository/admin_audit_log_repository.dart';

class GetAuditLog implements UseCase<AuditLogPage, NoParams> {
  const GetAuditLog(this._repository);

  final AdminAuditLogRepository _repository;

  @override
  Future<AuditLogPage> call(NoParams params) => _repository.getAuditLog();
}
