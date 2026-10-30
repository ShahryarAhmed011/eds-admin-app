part of 'auth_bloc.dart';

enum LoginMethod { email, phone }

sealed class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

final class AuthLoading extends AuthState {
  const AuthLoading();
}

final class AuthReady extends AuthState {
  const AuthReady({
    required this.selectedRole,
    required this.draft,
    this.loginMethod = LoginMethod.email,
    this.isSubmitting = false,
    this.error,
    this.errorReference,
    this.emailError,
    this.phoneError,
    this.signedIn,
    this.needsVerification = false,
  });

  final AppRole selectedRole;
  final AuthDraft draft;
  final LoginMethod loginMethod;
  final bool isSubmitting;

  bool get canSignIn => switch (loginMethod) {
    LoginMethod.email => draft.canSignIn,
    LoginMethod.phone => draft.canPhoneSignIn,
  };

  /// Form-level failure shown in a banner; the form keeps its values.
  final String? error;
  final String? errorReference;
  final String? emailError;
  final String? phoneError;

  /// One-shot: a session was created; navigate home.
  final SignedInUser? signedIn;

  /// One-shot: a code was sent (sign up, phone login or unverified email
  /// login); open the OTP screen.
  final bool needsVerification;

  AuthReady copyWith({
    AppRole? selectedRole,
    AuthDraft? draft,
    LoginMethod? loginMethod,
    bool isSubmitting = false,
    String? error,
    String? errorReference,
    String? emailError,
    String? phoneError,
    SignedInUser? signedIn,
    bool? needsVerification,
    bool clearErrors = false,
    bool clearOutcome = false,
  }) => AuthReady(
    selectedRole: selectedRole ?? this.selectedRole,
    draft: draft ?? this.draft,
    loginMethod: loginMethod ?? this.loginMethod,
    isSubmitting: isSubmitting,
    error: clearErrors ? null : error ?? this.error,
    errorReference: clearErrors ? null : errorReference ?? this.errorReference,
    emailError: clearErrors ? null : emailError ?? this.emailError,
    phoneError: clearErrors ? null : phoneError ?? this.phoneError,
    signedIn: clearOutcome ? null : signedIn ?? this.signedIn,
    needsVerification: clearOutcome
        ? false
        : needsVerification ?? this.needsVerification,
  );

  @override
  List<Object?> get props => [
    selectedRole,
    draft,
    loginMethod,
    isSubmitting,
    error,
    errorReference,
    emailError,
    phoneError,
    signedIn,
    needsVerification,
  ];
}

final class AuthFailure extends AuthState {
  const AuthFailure(this.message, {this.reference});

  final String message;
  final String? reference;

  @override
  List<Object?> get props => [message, reference];
}
