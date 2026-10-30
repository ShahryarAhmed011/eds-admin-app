import '../../../../../core/core.dart';
import '../dto/audit_entry_dto.dart';
import 'admin_audit_log_data_source.dart';

/// Prefilled data matching the Figma audit log.
class AdminAuditLogDummyDataSource implements AdminAuditLogDataSource {
  static final _asOf = DateTime.parse('2026-10-16T12:00:00+05:00');

  static const _data = {
    'items': [
      {
        'id': 9001,
        'entityType': 'shop',
        'entityCode': 'SH-025',
        'entityName': 'City Essentials',
        'action': 'set_live',
        'actorName': 'Nadia',
        'fromStatus': 'approved',
        'toStatus': 'live',
        'reason': 'Identity, stock and service area verified.',
        'createdAt': '2026-10-16T09:38:00+05:00',
      },
      {
        'id': 9000,
        'entityType': 'kyc',
        'entityCode': 'KYC-306',
        'action': 'approved',
        'actorName': 'Hamza',
        'reason': 'Clear documents; name and expiry verified.',
        'createdAt': '2026-10-16T09:25:00+05:00',
      },
      {
        'id': 8999,
        'entityType': 'catalog_variant',
        'entityCode': 'SKU-010',
        'action': 'updated',
        'actorName': 'Nadia',
        'reason': 'Corrected pack size from 500 g to 1 kg.',
        'createdAt': '2026-10-16T09:10:00+05:00',
      },
      {
        'id': 8990,
        'entityType': 'user',
        'entityCode': 'USR-052',
        'entityName': 'Kamran Shah',
        'action': 'suspended',
        'actorName': 'Hamza',
        'fromStatus': 'active',
        'toStatus': 'suspended',
        'reason': 'Misleading listings reported by three customers.',
        'createdAt': '2026-10-12T18:40:00+05:00',
      },
      {
        'id': 8985,
        'entityType': 'product_request',
        'entityCode': 'REQ-095',
        'action': 'rejected',
        'actorName': 'Nadia',
        'reason': 'Duplicate of SKU-002.',
        'createdAt': '2026-10-13T11:20:00+05:00',
      },
    ],
  };

  @override
  Future<AuditLogPageDto> fetchAuditLog() async {
    await dummyDelay();
    return AuditLogPageDto.fromData(_data, asOf: _asOf);
  }
}
