import '../../../../../core/core.dart';

/// Presentation helpers for [AppRole].
extension AppRoleUi on AppRole {
  /// Admin accounts are provisioned, not self-registered: the admin app
  /// has no sign up.
  bool get canSelfRegister => this != AppRole.admin;
}
