import 'package:eds_admin_app/features/admin/audit_log/data/dto/audit_entry_dto.dart';
import 'package:eds_admin_app/features/admin/audit_log/data/mappers/audit_entry_mapper.dart';
import 'package:eds_admin_app/features/admin/audit_log/domain/entities/audit_entry.dart';
import 'package:eds_admin_app/features/admin/audit_log/presentation/widgets/admin_time_format.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final asOf = DateTime.utc(2026, 10, 16, 7);

  test('parses an items payload with likely key names', () {
    final page = AuditLogPageDto.fromData({
      'items': [
        {
          'id': 1,
          'entityType': 'shop',
          'entityCode': 'SH-025',
          'entityName': 'City Essentials',
          'action': 'set_live',
          'actor': {'name': 'Nadia'},
          'fromStatus': 'approved',
          'toStatus': 'live',
          'reason': 'Verified.',
          'createdAt': '2026-10-16T04:38:00Z',
        },
      ],
    }, asOf: asOf).toEntity();

    final entry = page.entries.single;
    expect(entry.category, 'Shop');
    expect(entry.action, 'Set live');
    expect(entry.actorName, 'Nadia');
    expect(entry.entityRef, 'SH-025');
    expect(entry.detail, 'City Essentials · Approved → Live');
    expect(entry.tone, AuditEntryTone.positive);
    expect(formatAdminTime(entry.occurredAt!), '9:38 am');
  });

  test('accepts a bare list and falls back on missing fields', () {
    final page = AuditLogPageDto.fromData([
      {'id': 2, 'entityType': 'kyc', 'entityId': 306, 'action': 'approved'},
    ], asOf: asOf).toEntity();

    final entry = page.entries.single;
    expect(entry.category, 'KYC');
    expect(entry.entityRef, 'kyc #306');
    expect(entry.actorName, 'System');
    expect(entry.occurredAt, isNull);
  });

  test('unknown shapes become an empty log', () {
    expect(AuditLogPageDto.fromData('nope', asOf: asOf).items, isEmpty);
    expect(AuditLogPageDto.fromData({'foo': 1}, asOf: asOf).items, isEmpty);
    expect(AuditLogPageDto.fromData(null, asOf: asOf).items, isEmpty);
  });
}
