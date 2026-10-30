import 'package:equatable/equatable.dart';

import '../../../../../core/core.dart';

/// A verification code that has been sent: a sign-up / email code for
/// [email], a phone login code for [phoneNumber], or (with
/// [verifiesAccountPhone]) a code for the signed-in account's phone.
/// [role] is null unless known (sign up); the API decides it on verify.
class OtpChallenge extends Equatable {
  const OtpChallenge({
    required this.email,
    this.role,
    required this.sentTo,
    this.phoneNumber,
    this.length = defaultLength,
    this.expiresAt,
    this.resendAvailableAt,
    this.verifiesAccountPhone = false,
    this.verifiesAccountEmail = false,
  });

  static const defaultLength = 6;

  /// Empty for a phone login code.
  final String email;
  final AppRole? role;

  /// National digits (e.g. `3001234567`) for a phone login code.
  final String? phoneNumber;

  /// Onboarding: verifying the phone of the account that is signed in.
  final bool verifiesAccountPhone;

  /// Onboarding: verifying the email of the account that is signed in
  /// (an email login).
  final bool verifiesAccountEmail;

  /// An onboarding verification of the signed-in account: back signs out.
  bool get verifiesAccount => verifiesAccountPhone || verifiesAccountEmail;

  /// Sent by SMS (a phone login or the account's phone).
  bool get isPhone => phoneNumber != null || verifiesAccountPhone;

  /// Where the code went (usually the email address, possibly masked).
  final String sentTo;
  final int length;
  final DateTime? expiresAt;
  final DateTime? resendAvailableAt;

  @override
  List<Object?> get props => [
    email,
    role,
    phoneNumber,
    sentTo,
    length,
    expiresAt,
    resendAvailableAt,
    verifiesAccountPhone,
    verifiesAccountEmail,
  ];
}
