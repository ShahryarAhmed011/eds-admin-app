import 'package:flutter/material.dart';

import '../../../common/admin_common.dart';
import '../../domain/entities/admin_user.dart';
import 'admin_user_labels.dart';

typedef UserAccessChoice = ({AdminUserAccessAction action, String reason});

/// Order of options in the "Manage account access" sheet.
const userAccessOptions = AdminUserAccessAction.values;

/// Suggested action for a user's current status.
AdminUserAccessAction? suggestedAccessAction(AdminUserStatus status) =>
    switch (status) {
      AdminUserStatus.flagged => AdminUserAccessAction.suspend,
      AdminUserStatus.suspended => AdminUserAccessAction.restore,
      AdminUserStatus.active ||
      AdminUserStatus.pending ||
      AdminUserStatus.unknown => null,
    };

Future<UserAccessChoice?> showUserAccessSheet(
  BuildContext context, {
  required AdminUser user,
  AdminUserAccessAction? preset,
  String? initialReason,
}) async {
  preset ??= suggestedAccessAction(user.status);
  final result = await showAdminDecisionSheet(
    context,
    title: 'Manage account access',
    subtitle: '${user.reference} · ${user.name} · ${user.role.label}',
    initialIndex: preset == null ? null : userAccessOptions.indexOf(preset),
    initialReason: initialReason,
    options: const [
      AdminDecisionOption(
        label: 'Keep active · Resolve flag',
        confirmLabel: 'Confirm · Keep active',
        suggestedReason:
            'Reports reviewed and resolved with the user. No further '
            'action needed.',
      ),
      AdminDecisionOption(
        label: 'Suspend account',
        confirmLabel: 'Confirm suspension',
        destructive: true,
        suggestedReason:
            'Repeated inaccurate stock reports. Access suspended pending '
            'support review.',
      ),
      AdminDecisionOption(
        label: 'Restore access',
        confirmLabel: 'Confirm · Restore access',
        suggestedReason:
            'Support review completed. Access restored with a final warning.',
      ),
    ],
  );
  if (result == null) return null;
  return (action: userAccessOptions[result.optionIndex], reason: result.reason);
}
