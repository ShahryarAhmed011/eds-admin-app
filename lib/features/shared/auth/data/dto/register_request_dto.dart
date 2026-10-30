import '../../../../../core/core.dart';

/// Body of `POST /auth/signup`. The role goes out as a numeric `roleId`.
class RegisterRequestDto {
  const RegisterRequestDto({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.password,
    required this.role,
    required this.phoneCountryCode,
    required this.phoneNumber,
  });

  /// `roleId` for each self-registering role (an `AppRole.apiValue`).
  static const roleIds = {'customer': 2, 'rider': 3, 'retailer': 4};

  final String firstName;
  final String lastName;
  final String email;
  final String password;

  /// An `AppRole.apiValue`; sent as [roleIds] `[role]`.
  final String role;
  final String phoneCountryCode;
  final String phoneNumber;

  Json toJson() => {
    'firstName': firstName,
    'lastName': lastName,
    'email': email,
    'password': password,
    'roleId': roleIds[role] ?? (throw ArgumentError.value(role, 'role')),
    'phoneCountryCode': phoneCountryCode,
    'phoneNumber': phoneNumber,
  };
}
