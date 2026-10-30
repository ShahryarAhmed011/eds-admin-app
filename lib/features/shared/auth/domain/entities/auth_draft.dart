import 'package:equatable/equatable.dart';

/// Values of the sign in / sign up forms.
class AuthDraft extends Equatable {
  const AuthDraft({
    this.firstName = '',
    this.lastName = '',
    this.email = '',
    this.password = '',
    this.phoneNumber = '',
    this.acceptedTerms = false,
    this.rememberMe = true,
  });

  final String firstName;
  final String lastName;
  final String email;
  final String password;

  /// National digits without the `+92` prefix, e.g. `3001234567`.
  final String phoneNumber;
  final bool acceptedTerms;

  /// Sign in: save the phone number on this device for next time. On by
  /// default.
  final bool rememberMe;

  bool get canSignIn => email.trim().isNotEmpty && password.isNotEmpty;

  /// A full national mobile number (10 digits, e.g. `3001234567`).
  bool get canRequestPhoneCode => phoneNumber.length == 10;

  /// Phone sign in: a full number and a password.
  bool get canPhoneSignIn => canRequestPhoneCode && password.isNotEmpty;

  // Sign up, one getter per step.

  bool get hasName => firstName.trim().isNotEmpty && lastName.trim().isNotEmpty;

  bool get hasValidEmail => _email.hasMatch(email.trim());

  /// A valid email and a full mobile number.
  bool get hasContact => hasValidEmail && canRequestPhoneCode;

  /// At least 8 characters, with a letter and a number.
  bool get hasStrongPassword =>
      password.length >= 8 &&
      password.contains(RegExp('[A-Za-z]')) &&
      password.contains(RegExp('[0-9]'));

  bool get canSignUp =>
      hasName && hasContact && hasStrongPassword && acceptedTerms;

  static final _email = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  AuthDraft copyWith({
    String? firstName,
    String? lastName,
    String? email,
    String? password,
    String? phoneNumber,
    bool? acceptedTerms,
    bool? rememberMe,
  }) => AuthDraft(
    firstName: firstName ?? this.firstName,
    lastName: lastName ?? this.lastName,
    email: email ?? this.email,
    password: password ?? this.password,
    phoneNumber: phoneNumber ?? this.phoneNumber,
    acceptedTerms: acceptedTerms ?? this.acceptedTerms,
    rememberMe: rememberMe ?? this.rememberMe,
  );

  @override
  List<Object?> get props => [
    firstName,
    lastName,
    email,
    password,
    phoneNumber,
    acceptedTerms,
    rememberMe,
  ];
}
