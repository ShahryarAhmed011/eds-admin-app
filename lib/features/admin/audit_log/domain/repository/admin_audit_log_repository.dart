import '../entities/audit_entry.dart';

abstract interface class AdminAuditLogRepository {
  Future<AuditLogPage> getAuditLog();
}
