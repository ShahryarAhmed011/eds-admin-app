import '../dto/audit_entry_dto.dart';

abstract interface class AdminAuditLogDataSource {
  Future<AuditLogPageDto> fetchAuditLog();
}
