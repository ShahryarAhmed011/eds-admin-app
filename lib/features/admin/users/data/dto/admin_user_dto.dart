import '../../../../../core/core.dart';

/// One user from `GET /admin/users` / `PATCH /admin/users/{id}/status`.
///
/// Fields after [createdAt] are not provided by the API yet; only the dummy
/// data source fills them (Figma copy). They are null from remote.
class AdminUserDto {
  const AdminUserDto({
    required this.id,
    required this.fullName,
    required this.email,
    required this.role,
    required this.status,
    required this.onboardingStatus,
    this.createdAt,
    this.phone,
    this.location,
    this.flagReason,
    this.severity,
    this.alertTitle,
    this.alertMessage,
    this.shopId,
    this.shopName,
    this.shopStatusLabel,
    this.identityVerifiedAt,
    this.lastSignInAt,
  });

  factory AdminUserDto.fromJson(Json json) => AdminUserDto(
    id: json.id(),
    fullName: json.strOr('fullName'),
    email: json.strOr('email'),
    role: json.strOr('role'),
    status: json.strOr('status'),
    onboardingStatus: json.strOr('onboardingStatus'),
    createdAt: json.date('createdAt'),
    phone: json.str('phone'),
    location: json.str('location'),
    flagReason: json.str('flagReason'),
    severity: json.str('severity'),
    alertTitle: json.str('alertTitle'),
    alertMessage: json.str('alertMessage'),
    shopId: json.str('shopId'),
    shopName: json.str('shopName'),
    shopStatusLabel: json.str('shopStatusLabel'),
    identityVerifiedAt: json.date('identityVerifiedAt'),
    lastSignInAt: json.date('lastSignInAt'),
  );

  final String id;
  final String fullName;
  final String email;
  final String role;
  final String status;
  final String onboardingStatus;
  final DateTime? createdAt;

  // Not in the API yet.
  final String? phone;
  final String? location;
  final String? flagReason;
  final String? severity;
  final String? alertTitle;
  final String? alertMessage;
  final String? shopId;
  final String? shopName;
  final String? shopStatusLabel;
  final DateTime? identityVerifiedAt;
  final DateTime? lastSignInAt;
}

/// Status strings sent to / filtered on the API. The API does not document
/// its user status set; these are the values this app assumes.
abstract final class AdminUserApiStatus {
  static const active = 'active';
  static const flagged = 'flagged';
  static const suspended = 'suspended';
}
