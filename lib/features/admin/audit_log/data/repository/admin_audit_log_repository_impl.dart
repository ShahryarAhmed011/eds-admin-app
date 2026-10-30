import '../../domain/entities/audit_entry.dart';
import '../../domain/repository/admin_audit_log_repository.dart';
import '../data_sources/admin_audit_log_data_source.dart';
import '../mappers/audit_entry_mapper.dart';

class AdminAuditLogRepositoryImpl implements AdminAuditLogRepository {
  const AdminAuditLogRepositoryImpl(this._dataSource);

  final AdminAuditLogDataSource _dataSource;

  @override
  Future<AuditLogPage> getAuditLog() async =>
      (await _dataSource.fetchAuditLog()).toEntity();
}
