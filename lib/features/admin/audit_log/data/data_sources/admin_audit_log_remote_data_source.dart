import '../../../../../core/core.dart';
import '../dto/audit_entry_dto.dart';
import 'admin_audit_log_data_source.dart';

class AdminAuditLogRemoteDataSource implements AdminAuditLogDataSource {
  const AdminAuditLogRemoteDataSource(this._api);

  final ApiClient _api;

  /// `GET /admin/audit-logs` — shape is unmodelled; parsed defensively.
  @override
  Future<AuditLogPageDto> fetchAuditLog() async => AuditLogPageDto.fromData(
    await _api.get('/admin/audit-logs'),
    asOf: DateTime.now(),
  );
}
