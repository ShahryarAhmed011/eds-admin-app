import '../../../../../core/core.dart';

/// `GET /admin/audit-logs` is not modelled in the API schema, so every field
/// is read defensively from the most likely key names.
class AuditEntryDto {
  const AuditEntryDto({
    required this.id,
    this.entityType,
    this.entityId,
    this.entityCode,
    this.entityName,
    this.action,
    this.actorName,
    this.fromStatus,
    this.toStatus,
    this.reason,
    this.createdAt,
  });

  factory AuditEntryDto.fromJson(Json json) {
    final actor = json.obj('actor');
    String? first(List<String> keys) {
      for (final key in keys) {
        final value = json.str(key);
        if (value != null && value.isNotEmpty) return value;
      }
      return null;
    }

    return AuditEntryDto(
      id: json.id(),
      entityType: first(['entityType', 'targetType', 'resourceType']),
      entityId: first(['entityId', 'targetId', 'resourceId']),
      entityCode: first(['entityCode', 'targetCode', 'entityRef']),
      entityName: first(['entityName', 'targetName']),
      action: first(['action', 'event', 'eventType']),
      actorName:
          first(['actorName', 'adminName', 'performedBy']) ??
          actor?.str('name') ??
          actor?.str('fullName'),
      fromStatus: first(['fromStatus', 'oldStatus', 'previousStatus']),
      toStatus: first(['toStatus', 'newStatus', 'status']),
      reason: first(['reason', 'note', 'comment']),
      createdAt: json.date('createdAt') ?? json.date('occurredAt'),
    );
  }

  final String id;
  final String? entityType;
  final String? entityId;
  final String? entityCode;
  final String? entityName;
  final String? action;
  final String? actorName;
  final String? fromStatus;
  final String? toStatus;
  final String? reason;
  final DateTime? createdAt;
}

class AuditLogPageDto {
  const AuditLogPageDto({required this.asOf, required this.items});

  /// Accepts `{items: [...]}`, `{logs: [...]}` or a bare list; anything else
  /// becomes an empty log.
  factory AuditLogPageDto.fromData(Object? data, {required DateTime asOf}) {
    final List<Json> raw = switch (data) {
      final Map<dynamic, dynamic> map => () {
        final json = map.cast<String, dynamic>();
        final items = json.objList('items');
        return items.isNotEmpty ? items : json.objList('logs');
      }(),
      final List<dynamic> list =>
        list.whereType<Map>().map((e) => e.cast<String, dynamic>()).toList(),
      _ => const <Json>[],
    };
    return AuditLogPageDto(
      asOf: asOf,
      items: [for (final item in raw) AuditEntryDto.fromJson(item)],
    );
  }

  final DateTime asOf;
  final List<AuditEntryDto> items;
}
