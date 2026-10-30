import 'package:equatable/equatable.dart';

enum AuditEntryTone { positive, negative, neutral }

class AuditEntry extends Equatable {
  const AuditEntry({
    required this.id,
    required this.category,
    required this.action,
    required this.actorName,
    required this.entityRef,
    required this.tone,
    this.occurredAt,
    this.detail,
    this.reason,
  });

  final String id;

  /// "Shop", "KYC", "Catalogue"...
  final String category;

  /// "Set live", "Approved", "Updated"...
  final String action;
  final String actorName;

  /// What was acted on ("SH-025").
  final String entityRef;
  final AuditEntryTone tone;

  /// Null when the backend omits it.
  final DateTime? occurredAt;

  /// Extra context ("City Essentials · Approved → Live").
  final String? detail;
  final String? reason;

  @override
  List<Object?> get props => [
    id,
    category,
    action,
    actorName,
    entityRef,
    tone,
    occurredAt,
    detail,
    reason,
  ];
}

class AuditLogPage extends Equatable {
  const AuditLogPage({required this.asOf, required this.entries});

  /// "Now" for the Today filter.
  final DateTime asOf;
  final List<AuditEntry> entries;

  @override
  List<Object?> get props => [asOf, entries];
}
