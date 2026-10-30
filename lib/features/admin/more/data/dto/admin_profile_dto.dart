import '../../../../../core/core.dart';

/// `GET /profile` payload (fields the admin card uses).
class AdminProfileDto {
  const AdminProfileDto({
    required this.id,
    required this.email,
    required this.role,
    this.firstName,
    this.lastName,
    this.username,
    this.phoneCountryCode,
    this.phoneNumber,
    this.city,
    this.area,
  });

  factory AdminProfileDto.fromJson(Json json) => AdminProfileDto(
    id: json.id(),
    email: json.strOr('email'),
    role: json.strOr('role'),
    firstName: json.str('firstName'),
    lastName: json.str('lastName'),
    username: json.str('username'),
    phoneCountryCode: json.str('phoneCountryCode'),
    phoneNumber: json.str('phoneNumber'),
    city: json.str('city'),
    area: json.str('area'),
  );

  final String id;
  final String email;
  final String role;
  final String? firstName;
  final String? lastName;
  final String? username;
  final String? phoneCountryCode;
  final String? phoneNumber;
  final String? city;
  final String? area;
}
