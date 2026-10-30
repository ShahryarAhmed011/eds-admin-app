import '../../domain/entities/audit_entry.dart';
import '../dto/audit_entry_dto.dart';

/// "set_live" → "Set live".
String _humanize(String raw) {
  final words = raw.replaceAll(RegExp(r'[_\-.]+'), ' ').trim();
  if (words.isEmpty) return raw;
  return words[0].toUpperCase() + words.substring(1).toLowerCase();
}

String _category(String? type) => switch (type?.toLowerCase()) {
  null || '' => 'Activity',
  'kyc' || 'kyc_submission' => 'KYC',
  'catalog_variant' || 'catalogue' || 'catalog' || 'variant' => 'Catalogue',
  'product_request' => 'Product request',
  'area' || 'geo_area' => 'Area',
  final other => _humanize(other),
};

AuditEntryTone _tone(String action) {
  final a = action.toLowerCase();
  if (RegExp('approv|live|restor|activat|serviceable').hasMatch(a) &&
      !a.contains('deactivat')) {
    return AuditEntryTone.positive;
  }
  if (RegExp('reject|suspend|deactivat|block|not served').hasMatch(a)) {
    return AuditEntryTone.negative;
  }
  return AuditEntryTone.neutral;
}

extension AuditEntryDtoMapper on AuditEntryDto {
  AuditEntry toEntity() {
    final actionLabel = _humanize(action ?? 'updated');
    final transition = fromStatus != null && toStatus != null
        ? '${_humanize(fromStatus!)} → ${_humanize(toStatus!)}'
        : null;
    final detailParts = [?entityName, ?transition];
    return AuditEntry(
      id: id,
      category: _category(entityType),
      action: actionLabel,
      actorName: actorName ?? 'System',
      entityRef:
          entityCode ??
          [?entityType, ?entityId].join(' #').ifEmpty('Record $id'),
      tone: _tone(actionLabel),
      occurredAt: createdAt,
      detail: detailParts.isEmpty ? null : detailParts.join(' · '),
      reason: reason,
    );
  }
}

extension AuditLogPageDtoMapper on AuditLogPageDto {
  AuditLogPage toEntity() => AuditLogPage(
    asOf: asOf,
    entries: [for (final item in items) item.toEntity()],
  );
}

extension on String {
  String ifEmpty(String fallback) => isEmpty ? fallback : this;
}
