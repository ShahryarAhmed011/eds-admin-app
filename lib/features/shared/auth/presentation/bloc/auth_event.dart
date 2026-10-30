part of 'auth_bloc.dart';

sealed class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

final class AuthStarted extends AuthEvent {
  const AuthStarted({
    this.loginMethod = LoginMethod.email,
    this.prefill = true,
  });

  /// How [AuthSignInSubmitted] signs in on this screen.
  final LoginMethod loginMethod;

  /// Fill the form with remembered values; off for sign up, which always
  /// starts blank.
  final bool prefill;

  @override
  List<Object?> get props => [loginMethod, prefill];
}

/// Any form field edit. Only non-null values are applied.
final class AuthDraftChanged extends AuthEvent {
  const AuthDraftChanged({
    this.firstName,
    this.lastName,
    this.email,
    this.password,
    this.phoneNumber,
    this.acceptedTerms,
    this.rememberMe,
  });

  final String? firstName;
  final String? lastName;
  final String? email;
  final String? password;
  final String? phoneNumber;
  final bool? acceptedTerms;
  final bool? rememberMe;

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

/// Sign in switches between the phone and email fields.
final class AuthLoginMethodChanged extends AuthEvent {
  const AuthLoginMethodChanged(this.method);

  final LoginMethod method;

  @override
  List<Object?> get props => [method];
}

final class AuthSignInSubmitted extends AuthEvent {
  const AuthSignInSubmitted();
}

final class AuthSignUpSubmitted extends AuthEvent {
  const AuthSignUpSubmitted();
}
