import '../../domain/entities/admin_user.dart';
import '../dto/admin_user_dto.dart';

extension AdminUserDtoMapper on AdminUserDto {
  AdminUser toEntity() => AdminUser(
    id: id,
    name: fullName.trim().isEmpty ? email : fullName.trim(),
    email: email,
    role: adminUserRoleFromApi(role),
    status: adminUserStatusFromApi(status),
    rawStatus: status,
    onboardingStatus: onboardingStatus,
    createdAt: createdAt,
    phone: phone,
    location: location,
    flagReason: flagReason,
    severity: switch (severity) {
      'high' => AdminUserSeverity.high,
      'medium' || 'low' => AdminUserSeverity.medium,
      _ => null,
    },
    alertTitle: alertTitle,
    alertMessage: alertMessage,
    shop: shopId == null
        ? null
        : AdminLinkedShop(
            id: shopId!,
            name: shopName ?? shopId!,
            statusLabel: shopStatusLabel ?? '',
          ),
    identityVerifiedAt: identityVerifiedAt,
    lastSignInAt: lastSignInAt,
  );
}

AdminUserRole adminUserRoleFromApi(String raw) => switch (raw.toLowerCase()) {
  'customer' => AdminUserRole.customer,
  'retailer' => AdminUserRole.retailer,
  'rider' => AdminUserRole.rider,
  'admin' => AdminUserRole.admin,
  _ => AdminUserRole.other,
};

AdminUserStatus adminUserStatusFromApi(String raw) =>
    switch (raw.toLowerCase()) {
      'active' || 'enabled' => AdminUserStatus.active,
      'flagged' || 'under_review' || 'review' => AdminUserStatus.flagged,
      'suspended' ||
      'disabled' ||
      'banned' ||
      'blocked' => AdminUserStatus.suspended,
      'pending' || 'inactive' || 'unverified' => AdminUserStatus.pending,
      _ => AdminUserStatus.unknown,
    };

/// API status string to filter a status tab on.
String? adminUserStatusToApi(AdminUserStatus? status) => switch (status) {
  null => null,
  AdminUserStatus.active => AdminUserApiStatus.active,
  AdminUserStatus.flagged => AdminUserApiStatus.flagged,
  AdminUserStatus.suspended => AdminUserApiStatus.suspended,
  AdminUserStatus.pending => 'pending',
  AdminUserStatus.unknown => null,
};

/// API status string an access action sets.
String adminUserActionToApi(AdminUserAccessAction action) => switch (action) {
  AdminUserAccessAction.keepActive => AdminUserApiStatus.active,
  AdminUserAccessAction.suspend => AdminUserApiStatus.suspended,
  AdminUserAccessAction.restore => AdminUserApiStatus.active,
};
