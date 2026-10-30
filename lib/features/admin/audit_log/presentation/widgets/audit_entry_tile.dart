import 'package:flutter/material.dart';

import '../../../../../core/core.dart';
import '../../domain/entities/audit_entry.dart';
import 'admin_time_format.dart';

/// One audit record: category badge, "time · actor → entity", optional
/// detail line and the reason.
class AuditEntryTile extends StatelessWidget {
  const AuditEntryTile({super.key, required this.entry, this.showDate = false});

  final AuditEntry entry;

  /// Prefix the time with the day for entries outside today.
  final bool showDate;

  @override
  Widget build(BuildContext context) {
    final at = entry.occurredAt;
    final when = at == null
        ? null
        : showDate
        ? formatAdminDayTime(at)
        : formatAdminTime(at);
    final tone = switch (entry.tone) {
      AuditEntryTone.positive => EdsTone.success,
      AuditEntryTone.negative => EdsTone.danger,
      AuditEntryTone.neutral => EdsTone.neutral,
    };
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          EdsBadge('${entry.category} · ${entry.action}', tone: tone),
          AppSpacing.gapSm,
          Text(
            [?when, '${entry.actorName} → ${entry.entityRef}'].join(' · '),
            style: AppTextStyles.bodyLarge.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          if (entry.detail != null) ...[
            AppSpacing.gapSm,
            Text(entry.detail!, style: AppTextStyles.bodySecondary),
          ],
          if (entry.reason != null) ...[
            AppSpacing.gapSm,
            Text('Reason: ${entry.reason}', style: AppTextStyles.body),
          ],
        ],
      ),
    );
  }
}
