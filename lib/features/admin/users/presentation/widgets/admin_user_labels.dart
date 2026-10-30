import '../../../../../core/core.dart';
import '../../../common/admin_common.dart';
import '../../domain/entities/admin_user.dart';

extension AdminUserRoleLabel on AdminUserRole {
  String get label => switch (this) {
    AdminUserRole.customer => 'Customer',
    AdminUserRole.retailer => 'Retailer',
    AdminUserRole.rider => 'Rider',
    AdminUserRole.admin => 'Admin',
    AdminUserRole.other => 'User',
  };
}

extension AdminUserBadge on AdminUser {
  String get badgeLabel => switch (status) {
    AdminUserStatus.active => 'Active',
    AdminUserStatus.flagged => 'Flagged',
    AdminUserStatus.suspended => 'Suspended',
    AdminUserStatus.pending => 'Pending',
    AdminUserStatus.unknown => AdminFormat.humanize(rawStatus),
  };

  EdsTone get badgeTone => switch (status) {
    AdminUserStatus.active => EdsTone.success,
    AdminUserStatus.suspended => EdsTone.danger,
    AdminUserStatus.flagged =>
      severity == AdminUserSeverity.medium ? EdsTone.warning : EdsTone.danger,
    AdminUserStatus.pending => EdsTone.warning,
    AdminUserStatus.unknown => EdsTone.neutral,
  };

  /// "USR-088 · Retailer · Stock complaints".
  String get listSubtitle =>
      [reference, role.label, flagReason ?? email].join(' · ');
}
