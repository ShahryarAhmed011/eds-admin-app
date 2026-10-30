part of 'admin_audit_log_bloc.dart';

/// Today's entries, every entry, or every entry grouped by admin.
enum AuditLogTab { today, allActions, allAdmins }

sealed class AdminAuditLogState extends Equatable {
  const AdminAuditLogState();

  @override
  List<Object?> get props => [];
}

final class AdminAuditLogLoading extends AdminAuditLogState {
  const AdminAuditLogLoading();
}

final class AdminAuditLogLoaded extends AdminAuditLogState {
  const AdminAuditLogLoaded({
    required this.page,
    this.tab = AuditLogTab.today,
    this.query = '',
  });

  final AuditLogPage page;
  final AuditLogTab tab;
  final String query;

  bool isToday(AuditEntry entry) {
    final at = entry.occurredAt;
    return at != null && isSameAdminDay(at, page.asOf);
  }

  List<AuditEntry> get visibleEntries {
    final q = query.trim().toLowerCase();
    final entries = [
      for (final entry in page.entries)
        if ((tab != AuditLogTab.today || isToday(entry)) &&
            (q.isEmpty ||
                entry.actorName.toLowerCase().contains(q) ||
                entry.entityRef.toLowerCase().contains(q) ||
                entry.category.toLowerCase().contains(q) ||
                entry.action.toLowerCase().contains(q)))
          entry,
    ];
    if (tab == AuditLogTab.allAdmins) {
      // Stable sort keeps newest-first order within each admin.
      final indexed = entries.indexed.toList()
        ..sort((a, b) {
          final byActor = a.$2.actorName.compareTo(b.$2.actorName);
          return byActor != 0 ? byActor : a.$1.compareTo(b.$1);
        });
      return [for (final (_, entry) in indexed) entry];
    }
    return entries;
  }

  AdminAuditLogLoaded copyWith({AuditLogTab? tab, String? query}) =>
      AdminAuditLogLoaded(
        page: page,
        tab: tab ?? this.tab,
        query: query ?? this.query,
      );

  @override
  List<Object?> get props => [page, tab, query];
}

final class AdminAuditLogFailure extends AdminAuditLogState {
  const AdminAuditLogFailure(this.message, {this.reference});

  final String message;
  final String? reference;

  @override
  List<Object?> get props => [message, reference];
}
