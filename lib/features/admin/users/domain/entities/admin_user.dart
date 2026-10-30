import 'package:equatable/equatable.dart';

enum AdminUserRole { customer, retailer, rider, admin, other }

/// [unknown] covers any status string the app doesn't know yet.
enum AdminUserStatus { active, flagged, suspended, pending, unknown }

enum AdminUserSeverity { medium, high }

/// Access decision taken from the "Manage account access" sheet.
enum AdminUserAccessAction { keepActive, suspend, restore }

class AdminLinkedShop extends Equatable {
  const AdminLinkedShop({
    required this.id,
    required this.name,
    required this.statusLabel,
  });

  final String id;
  final String name;
  final String statusLabel;

  @override
  List<Object?> get props => [id, name, statusLabel];
}

class AdminUser extends Equatable {
  const AdminUser({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.status,
    required this.rawStatus,
    required this.onboardingStatus,
    this.createdAt,
    this.phone,
    this.location,
    this.flagReason,
    this.severity,
    this.alertTitle,
    this.alertMessage,
    this.shop,
    this.identityVerifiedAt,
    this.lastSignInAt,
  });

  final String id;
  final String name;
  final String email;
  final AdminUserRole role;
  final AdminUserStatus status;

  /// Status as sent by the API, for labelling unknown values.
  final String rawStatus;
  final String onboardingStatus;
  final DateTime? createdAt;

  // Not provided by the API yet (null from remote).
  final String? phone;
  final String? location;
  final String? flagReason;
  final AdminUserSeverity? severity;
  final String? alertTitle;
  final String? alertMessage;
  final AdminLinkedShop? shop;
  final DateTime? identityVerifiedAt;
  final DateTime? lastSignInAt;

  /// "USR-088" for display, whatever the id format.
  String get reference => RegExp(r'^[A-Za-z]').hasMatch(id) ? id : 'USR-$id';

  /// Keeps the Figma-only extras when the API returns a bare record.
  AdminUser mergeFrom(AdminUser previous) => AdminUser(
    id: id,
    name: name.isEmpty ? previous.name : name,
    email: email.isEmpty ? previous.email : email,
    role: role == AdminUserRole.other ? previous.role : role,
    status: status,
    rawStatus: rawStatus,
    onboardingStatus: onboardingStatus.isEmpty
        ? previous.onboardingStatus
        : onboardingStatus,
    createdAt: createdAt ?? previous.createdAt,
    phone: phone ?? previous.phone,
    location: location ?? previous.location,
    flagReason: flagReason ?? previous.flagReason,
    severity: severity ?? previous.severity,
    alertTitle: alertTitle ?? previous.alertTitle,
    alertMessage: alertMessage ?? previous.alertMessage,
    shop: shop ?? previous.shop,
    identityVerifiedAt: identityVerifiedAt ?? previous.identityVerifiedAt,
    lastSignInAt: lastSignInAt ?? previous.lastSignInAt,
  );

  @override
  List<Object?> get props => [
    id,
    name,
    email,
    role,
    status,
    rawStatus,
    onboardingStatus,
    createdAt,
    phone,
    location,
    flagReason,
    severity,
    alertTitle,
    alertMessage,
    shop,
    identityVerifiedAt,
    lastSignInAt,
  ];
}
