import 'package:equatable/equatable.dart';

import '../../../../../core/core.dart';

class UserProfile extends Equatable {
  const UserProfile({
    required this.fullName,
    required this.email,
    required this.role,
    required this.phone,
    required this.language,
    required this.availableLanguages,
    this.city,
    this.phoneVerified,
    this.emailVerified,
  });

  /// First and last name joined; split again on save.
  final String fullName;

  /// Read-only: the API doesn't allow changing it here.
  final String email;
  final AppRole role;

  /// "+92 300 1234567", or empty when not set.
  final String phone;

  /// Kept on the device; the API has no language field.
  final String language;
  final List<String> availableLanguages;

  /// City name, when the API includes one.
  final String? city;

  /// Null when the API doesn't say.
  final bool? phoneVerified;
  final bool? emailVerified;

  UserProfile copyWith({String? fullName, String? phone, String? language}) =>
      UserProfile(
        fullName: fullName ?? this.fullName,
        email: email,
        role: role,
        phone: phone ?? this.phone,
        language: language ?? this.language,
        availableLanguages: availableLanguages,
        city: city,
        phoneVerified: phoneVerified,
        emailVerified: emailVerified,
      );

  @override
  List<Object?> get props => [
    fullName,
    email,
    role,
    phone,
    language,
    availableLanguages,
    city,
    phoneVerified,
    emailVerified,
  ];
}
