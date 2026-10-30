import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/core.dart';
import '../../../../../core/di/injection.dart';
import '../bloc/auth_bloc.dart';
import '../widgets/app_role_ui.dart';
import '../widgets/auth_navigation_listener.dart';
import '../widgets/auth_email_field.dart';
import '../widgets/auth_hero_layout.dart';
import '../widgets/auth_password_field.dart';
import '../widgets/auth_phone_field.dart';

/// "Log in or sign up": illustration on top, then email (or phone) and
/// password, Continue, and Google / Phone (or Email) below.
class SignInScreen extends StatelessWidget {
  const SignInScreen({super.key});

  static const _start = AuthStarted(loginMethod: LoginMethod.email);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<AuthBloc>()..add(_start),
      child: const AuthNavigationListener(child: _SignInView()),
    );
  }
}

class _SignInView extends StatelessWidget {
  const _SignInView();

  @override
  Widget build(BuildContext context) {
    // Read above the Scaffold, which hides the keyboard inset from its body.
    final keyboardOpen = MediaQuery.viewInsetsOf(context).bottom > 0;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        // Pinned to the bottom of the form screen; hidden while typing.
        bottomNavigationBar: keyboardOpen
            ? null
            : BlocBuilder<AuthBloc, AuthState>(
                buildWhen: (previous, current) =>
                    previous.runtimeType != current.runtimeType,
                builder: (context, state) =>
                    state is AuthReady && AppConfig.appRole.canSelfRegister
                    ? AuthBottomPrompt(
                        question: 'Don’t have an account?',
                        action: 'Sign up',
                        onTap: () => context.push(AppRoutes.signUp),
                      )
                    : const SizedBox.shrink(),
              ),
        body: BlocListener<AuthBloc, AuthState>(
          // Errors go to the global toast, so the form never shifts.
          listenWhen: (previous, current) =>
              current is AuthReady &&
              current.error != null &&
              (previous is! AuthReady || previous.error != current.error),
          listener: (context, state) => EdsToast.show(
            context,
            (state as AuthReady).error!,
            kind: EdsToastKind.error,
          ),
          child: BlocBuilder<AuthBloc, AuthState>(
            builder: (context, state) => switch (state) {
              AuthLoading() => const EdsLoadingView(),
              AuthFailure(:final message, :final reference) => SafeArea(
                child: EdsErrorView(
                  message: message,
                  reference: reference,
                  onRetry: () =>
                      context.read<AuthBloc>().add(SignInScreen._start),
                ),
              ),
              AuthReady() => AuthHeroLayout(
                form: _SignInForm(state, compact: keyboardOpen),
              ),
            },
          ),
        ),
      ),
    );
  }
}

class _SignInForm extends StatelessWidget {
  const _SignInForm(this.state, {required this.compact});

  final AuthReady state;

  /// Keyboard open: only the fields and Continue, so they fit above it.
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<AuthBloc>();
    final usePhone = state.loginMethod == LoginMethod.phone;
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.lg,
          AppSpacing.lg,
          AppSpacing.sm,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const _WelcomeHeading(),
            AppSpacing.gapXs,
            Text(
              'Log in or sign up',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodySecondary,
            ),
            AppSpacing.gapLg,
            // Phone or email, switched by the button under "or".
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: usePhone
                  ? AuthPhoneField(
                      key: const ValueKey(LoginMethod.phone),
                      label: null,
                      initialDigits: state.draft.phoneNumber,
                      textInputAction: TextInputAction.next,
                      onChanged: (digits) =>
                          bloc.add(AuthDraftChanged(phoneNumber: digits)),
                    )
                  : AuthEmailField(
                      key: const ValueKey(LoginMethod.email),
                      initialValue: state.draft.email,
                      onChanged: (value) =>
                          bloc.add(AuthDraftChanged(email: value)),
                    ),
            ),
            AppSpacing.gapMd,
            AuthPasswordField(
              label: null,
              hint: 'Password',
              initialValue: state.draft.password,
              onChanged: (value) => bloc.add(AuthDraftChanged(password: value)),
            ),
            AppSpacing.gapXs,
            _RememberMe(
              value: state.draft.rememberMe,
              onChanged: (value) =>
                  bloc.add(AuthDraftChanged(rememberMe: value)),
            ),
            AppSpacing.gapMd,
            EdsButton.primary(
              label: 'Continue',
              isLoading: state.isSubmitting,
              onPressed: state.canSignIn
                  ? () => bloc.add(const AuthSignInSubmitted())
                  : null,
            ),
            if (!compact) ...[
              AppSpacing.gapLg,
              const _OrDivider(),
              AppSpacing.gapLg,
              Row(
                children: [
                  Expanded(
                    child: _AltLoginButton(
                      label: 'Google',
                      glyph: Text(
                        'G',
                        style: AppTextStyles.itemTitleLarge.copyWith(
                          color: AppColors.crimson,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      onTap: () => EdsToast.of(
                        context,
                      ).show('Google sign-in is coming soon.'),
                    ),
                  ),
                  AppSpacing.gapMd,
                  Expanded(
                    // The other way to log in: Email while on phone, and
                    // back to Phone while on email.
                    child: _AltLoginButton(
                      label: usePhone ? 'Email' : 'Phone',
                      glyph: Icon(
                        usePhone ? Icons.mail_outline : Icons.phone_iphone,
                        size: AppSizes.iconSm,
                      ),
                      onTap: () => bloc.add(
                        AuthLoginMethodChanged(
                          usePhone ? LoginMethod.email : LoginMethod.phone,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// "Welcome back to" + the EDS wordmark (figma_ref/welcome.png), on one
/// line; scales down on narrow screens.
class _WelcomeHeading extends StatelessWidget {
  const _WelcomeHeading();

  static const _logoSize = 30.0;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      header: true,
      label: 'Welcome back to EDS',
      child: ExcludeSemantics(
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Welcome back to', style: AppTextStyles.headline),
              AppSpacing.gapSm,
              const EdsLogo(size: _logoSize, showTagline: false),
            ],
          ),
        ),
      ),
    );
  }
}

/// "Remember me": keeps the phone number on this device for next time.
class _RememberMe extends StatelessWidget {
  const _RememberMe({required this.value, required this.onChanged});

  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: InkWell(
        onTap: () => onChanged(!value),
        borderRadius: AppRadius.smAll,
        child: Padding(
          padding: const EdgeInsets.only(right: AppSpacing.sm),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Compact box so it sits close to the password field.
              Theme(
                data: Theme.of(context).copyWith(
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  visualDensity: VisualDensity.compact,
                ),
                child: EdsCheckbox(value: value, onChanged: onChanged),
              ),
              Text('Remember me', style: AppTextStyles.label),
            ],
          ),
        ),
      ),
    );
  }
}

class _OrDivider extends StatelessWidget {
  const _OrDivider();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(child: Divider()),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          child: Text('or', style: AppTextStyles.caption),
        ),
        const Expanded(child: Divider()),
      ],
    );
  }
}

/// Slim outlined button for another way to log in: a glyph and a label.
class _AltLoginButton extends StatelessWidget {
  const _AltLoginButton({
    required this.label,
    required this.glyph,
    required this.onTap,
  });

  static const _height = 44.0;

  final String label;
  final Widget glyph;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Continue with $label',
      excludeSemantics: true,
      child: Material(
        color: AppColors.white,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.mdAll,
          side: BorderSide(color: AppColors.border),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: AppRadius.mdAll,
          child: SizedBox(
            height: _height,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconTheme.merge(
                  data: const IconThemeData(color: AppColors.crimson),
                  child: glyph,
                ),
                AppSpacing.gapSm,
                Text(label, style: AppTextStyles.itemTitle),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
