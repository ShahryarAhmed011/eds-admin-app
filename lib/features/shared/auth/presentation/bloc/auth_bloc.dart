import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/core.dart';
import '../../domain/entities/auth_draft.dart';
import '../../domain/entities/auth_exceptions.dart';
import '../../domain/entities/auth_result.dart';
import '../../domain/entities/signed_in_user.dart';
import '../../domain/usecase/get_auth_draft.dart';
import '../../domain/usecase/login_with_phone.dart';
import '../../domain/usecase/sign_in.dart';
import '../../domain/usecase/sign_up.dart';

part 'auth_event.dart';
part 'auth_state.dart';

/// Serves the sign in and sign up screens. Sign in sends no role; a new
/// account gets this app's role ([AppConfig.appRole]) without asking.
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc(this._getDraft, this._signIn, this._loginWithPhone, this._signUp)
    : super(const AuthLoading()) {
    on<AuthStarted>(_onStarted);
    on<AuthDraftChanged>(_onDraftChanged);
    on<AuthLoginMethodChanged>(_onLoginMethodChanged);
    on<AuthSignInSubmitted>(_onSignIn);
    on<AuthSignUpSubmitted>(_onSignUp);
  }

  /// Short messages under the sign up field that's already taken.
  static const emailInUseError = 'Email address already in use';
  static const phoneInUseError = 'Phone number already in use';

  final GetAuthDraft _getDraft;
  final SignIn _signIn;
  final LoginWithPhone _loginWithPhone;
  final SignUp _signUp;

  Future<void> _onStarted(AuthStarted event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());
    try {
      final draft = event.prefill
          ? await _getDraft(const NoParams())
          : const AuthDraft();
      emit(
        AuthReady(
          selectedRole: AppConfig.appRole,
          draft: draft,
          loginMethod: event.loginMethod,
        ),
      );
    } catch (e) {
      emit(AuthFailure(errorMessage(e), reference: errorReference(e)));
    }
  }

  void _onDraftChanged(AuthDraftChanged event, Emitter<AuthState> emit) {
    final current = state;
    if (current is! AuthReady) return;
    emit(
      current.copyWith(
        draft: current.draft.copyWith(
          firstName: event.firstName,
          lastName: event.lastName,
          email: event.email,
          password: event.password,
          phoneNumber: event.phoneNumber,
          acceptedTerms: event.acceptedTerms,
          rememberMe: event.rememberMe,
        ),
        clearErrors: true,
      ),
    );
  }

  void _onLoginMethodChanged(
    AuthLoginMethodChanged event,
    Emitter<AuthState> emit,
  ) {
    final current = state;
    if (current is! AuthReady || current.isSubmitting) return;
    emit(current.copyWith(loginMethod: event.method, clearErrors: true));
  }

  Future<void> _onSignIn(
    AuthSignInSubmitted event,
    Emitter<AuthState> emit,
  ) async {
    final current = state;
    if (current is! AuthReady || current.isSubmitting) return;
    emit(current.copyWith(isSubmitting: true, clearErrors: true));
    if (current.loginMethod == LoginMethod.phone) {
      try {
        final draft = current.draft;
        final result = await _loginWithPhone(
          PhoneLoginParams(
            phoneNumber: draft.phoneNumber,
            password: draft.password,
            rememberMe: draft.rememberMe,
          ),
        );
        _complete(emit, switch (result) {
          AuthSignedIn(:final user) => current.copyWith(signedIn: user),
          AuthCodeSent() => current.copyWith(needsVerification: true),
        });
      } catch (e) {
        emit(current.copyWith(error: _signInError(e, current.loginMethod)));
      }
      return;
    }
    try {
      final user = await _signIn(
        SignInParams(
          email: current.draft.email,
          password: current.draft.password,
          rememberMe: current.draft.rememberMe,
        ),
      );
      _complete(emit, current.copyWith(signedIn: user));
    } on AccountNotVerifiedException {
      _complete(emit, current.copyWith(needsVerification: true));
    } catch (e) {
      emit(current.copyWith(error: _signInError(e, current.loginMethod)));
    }
  }

  Future<void> _onSignUp(
    AuthSignUpSubmitted event,
    Emitter<AuthState> emit,
  ) async {
    final current = state;
    if (current is! AuthReady || current.isSubmitting) return;
    emit(current.copyWith(isSubmitting: true, clearErrors: true));
    try {
      final result = await _signUp(
        SignUpParams(draft: current.draft, role: current.selectedRole),
      );
      _complete(emit, switch (result) {
        AuthSignedIn(:final user) => current.copyWith(signedIn: user),
        AuthCodeSent() => current.copyWith(needsVerification: true),
      });
    } on ApiException catch (e) {
      emit(switch (e.code) {
        ApiErrorCode.emailInUse => current.copyWith(
          emailError: emailInUseError,
        ),
        ApiErrorCode.phoneInUse => current.copyWith(
          phoneError: phoneInUseError,
        ),
        _ => current.copyWith(error: _signUpError(e)),
      });
    } catch (e) {
      emit(current.copyWith(error: _signUpError(e)));
    }
  }

  /// Emits a one-shot navigation outcome, then clears it.
  void _complete(Emitter<AuthState> emit, AuthReady outcome) {
    emit(outcome);
    emit(outcome.copyWith(clearOutcome: true));
  }

  /// Short, friendly sign in failure for the toast.
  static String _signInError(Object e, LoginMethod method) =>
      _networkError(e) ??
      switch (e) {
        // Signed into the wrong role's app: say which app to use.
        ApiException(code: ApiErrorCode.wrongApp, :final message) => message,
        ApiException(code: ApiErrorCode.invalidCredentials) ||
        ApiException(status: 401) => switch (method) {
          LoginMethod.phone => 'Wrong phone number or password.',
          LoginMethod.email => 'Wrong email or password.',
        },
        ApiException(code: ApiErrorCode.rateLimited) =>
          'Too many attempts. Wait a minute and try again.',
        _ => 'Couldn’t log you in. Please try again.',
      };

  /// Short, friendly sign up failure for the toast.
  static String _signUpError(Object e) =>
      _networkError(e) ?? 'Couldn’t create your account. Please try again.';

  static String? _networkError(Object e) => switch (e) {
    ApiException(code: ApiErrorCode.networkUnavailable) =>
      'No internet connection. Check it and try again.',
    ApiException(code: ApiErrorCode.timeout) =>
      'The server took too long. Please try again.',
    _ => null,
  };
}
