import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/core.dart';
import '../../../../../core/di/injection.dart';
import '../../domain/entities/auth_draft.dart';
import '../../../common/same_height_steps.dart';
import '../bloc/auth_bloc.dart';
import '../widgets/auth_email_field.dart';
import '../widgets/auth_focus_theme.dart';
import '../widgets/auth_hero_layout.dart';
import '../widgets/auth_navigation_listener.dart';
import '../widgets/auth_password_field.dart';
import '../widgets/auth_phone_field.dart';

/// "Create your account" in three steps, in the sign in screen's layout:
/// name → email and phone → password and terms → Create account, then the
/// email is verified on the OTP screen. The account gets this app's role;
/// there is nothing to choose.
class SignUpScreen extends StatelessWidget {
  const SignUpScreen({super.key});

  /// Always a blank form: nothing remembered from a previous login.
  static const _start = AuthStarted(prefill: false);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<AuthBloc>()..add(SignUpScreen._start),
      child: const AuthNavigationListener(child: _SignUpView()),
    );
  }
}

enum _Step { name, contact, security }

class _SignUpView extends StatefulWidget {
  const _SignUpView();

  @override
  State<_SignUpView> createState() => _SignUpViewState();
}

class _SignUpViewState extends State<_SignUpView> {
  _Step _step = _Step.name;

  void _next() => setState(() => _step = _Step.values[_step.index + 1]);

  /// Previous step, or back to log in from the first.
  void _back() {
    if (_step == _Step.name) {
      _toLogIn(context);
    } else {
      setState(() => _step = _Step.values[_step.index - 1]);
    }
  }

  static void _toLogIn(BuildContext context) =>
      context.canPop() ? context.pop() : context.go(AppRoutes.signIn);

  @override
  Widget build(BuildContext context) {
    // Read above the Scaffold, which hides the keyboard inset from its body.
    final keyboardOpen = MediaQuery.viewInsetsOf(context).bottom > 0;
    return PopScope(
      // System back walks back through the steps first.
      canPop: _step == _Step.name,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _back();
      },
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.dark,
        child: Scaffold(
          bottomNavigationBar: keyboardOpen
              ? null
              : BlocBuilder<AuthBloc, AuthState>(
                  buildWhen: (previous, current) =>
                      previous.runtimeType != current.runtimeType,
                  builder: (context, state) => state is AuthReady
                      ? AuthBottomPrompt(
                          question: 'Already have an account?',
                          action: 'Log in',
                          onTap: () => _toLogIn(context),
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
            child: BlocConsumer<AuthBloc, AuthState>(
              // "Email / phone already in use" is answered on the last step:
              // go back to the step with those fields and explain in a toast.
              listenWhen: (previous, current) =>
                  current is AuthReady &&
                  (current.emailError != null || current.phoneError != null) &&
                  (previous is! AuthReady ||
                      previous.emailError != current.emailError ||
                      previous.phoneError != current.phoneError),
              listener: (context, state) {
                setState(() => _step = _Step.contact);
                final phoneTaken = (state as AuthReady).phoneError != null;
                EdsToast.show(
                  context,
                  phoneTaken
                      ? 'This phone number is already registered. '
                            'Try another, or log in.'
                      : 'This email is already registered. '
                            'Try another, or log in.',
                  kind: EdsToastKind.error,
                );
              },
              builder: (context, state) => switch (state) {
                AuthLoading() => const EdsLoadingView(),
                AuthFailure(:final message, :final reference) => SafeArea(
                  child: EdsErrorView(
                    message: message,
                    reference: reference,
                    onRetry: () =>
                        context.read<AuthBloc>().add(SignUpScreen._start),
                  ),
                ),
                AuthReady() => AuthHeroLayout(
                  onBack: _back,
                  divider: _StepProgressLine(
                    step: _step.index + 1,
                    total: _Step.values.length,
                  ),
                  form: _SignUpForm(state: state, step: _step, onNext: _next),
                ),
              },
            ),
          ),
        ),
      ),
    );
  }
}

/// "STEP 2 OF 4", the step's title, its fields, then Next (Create account
/// on the last step) right under them.
class _SignUpForm extends StatelessWidget {
  const _SignUpForm({
    required this.state,
    required this.step,
    required this.onNext,
  });

  final AuthReady state;
  final _Step step;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<AuthBloc>();
    final draft = state.draft;
    final isLast = step == _Step.security;
    final canContinue = switch (step) {
      _Step.name => draft.hasName,
      _Step.contact => draft.hasContact,
      _Step.security => draft.canSignUp,
    };
    final (title, subtitle) = switch (step) {
      _Step.name => (
        'What’s your name?',
        'This is how ${state.selectedRole.seenBy} will see you.',
      ),
      _Step.contact => (
        'How can we reach you?',
        'We’ll send a 6-digit code to verify your email.',
      ),
      _Step.security => (
        'Secure your account',
        'Last step: protect your account with a password.',
      ),
    };

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.xl,
          AppSpacing.lg,
          AppSpacing.md,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'STEP ${step.index + 1} OF ${_Step.values.length}',
              textAlign: TextAlign.center,
              style: AppTextStyles.eyebrow.copyWith(color: AppColors.crimson),
            ),
            AppSpacing.gapXs,
            Text(
              title,
              textAlign: TextAlign.center,
              style: AppTextStyles.headline,
            ),
            AppSpacing.gapXs,
            Text(
              subtitle,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.bodySecondary,
            ),
            AppSpacing.gapLg,
            // Slides the next step in from the side.
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              transitionBuilder: (child, animation) => FadeTransition(
                opacity: animation,
                child: SlideTransition(
                  position: Tween(
                    begin: const Offset(0.08, 0),
                    end: Offset.zero,
                  ).animate(animation),
                  child: child,
                ),
              ),
              child: KeyedSubtree(
                key: ValueKey(step),
                child: AuthFocusTheme(
                  // Name, contact and password take the height of the
                  // tallest, so the button stays put across them.
                  child: SameHeightSteps(
                    shown: step.index,
                    children: [
                      _NameStep(draft: draft),
                      _ContactStep(state: state),
                      _SecurityStep(draft: draft),
                    ],
                  ),
                ),
              ),
            ),
            AppSpacing.gapXl,
            isLast
                ? EdsButton.primary(
                    label: 'Create account',
                    isLoading: state.isSubmitting,
                    onPressed: canContinue
                        ? () => bloc.add(const AuthSignUpSubmitted())
                        : null,
                  )
                : EdsButton.primary(
                    label: 'Next',
                    onPressed: canContinue ? onNext : null,
                  ),
          ],
        ),
      ),
    );
  }
}

/// The line under the illustration doubles as progress: a light track that
/// fills with Crimson step by step.
class _StepProgressLine extends StatelessWidget {
  const _StepProgressLine({required this.step, required this.total});

  static const _height = 3.0;

  final int step;
  final int total;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Step $step of $total',
      child: SizedBox(
        height: _height,
        child: ColoredBox(
          color: AppColors.skeleton,
          child: AnimatedFractionallySizedBox(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
            alignment: Alignment.centerLeft,
            widthFactor: step / total,
            child: const ColoredBox(color: AppColors.crimson),
          ),
        ),
      ),
    );
  }
}

// Steps ----------------------------------------------------------------------

class _NameStep extends StatelessWidget {
  const _NameStep({required this.draft});

  final AuthDraft draft;

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<AuthBloc>();
    return Column(
      children: [
        EdsTextField(
          hint: 'First name',
          initialValue: draft.firstName,
          prefix: const Icon(Icons.person_outline),
          textInputAction: TextInputAction.next,
          onChanged: (value) => bloc.add(AuthDraftChanged(firstName: value)),
        ),
        AppSpacing.gapLg,
        EdsTextField(
          hint: 'Last name',
          initialValue: draft.lastName,
          prefix: const Icon(Icons.badge_outlined),
          textInputAction: TextInputAction.done,
          onChanged: (value) => bloc.add(AuthDraftChanged(lastName: value)),
        ),
      ],
    );
  }
}

class _ContactStep extends StatelessWidget {
  const _ContactStep({required this.state});

  final AuthReady state;

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<AuthBloc>();
    return Column(
      children: [
        AuthEmailField(
          initialValue: state.draft.email,
          errorText: state.emailError,
          onChanged: (value) => bloc.add(AuthDraftChanged(email: value)),
        ),
        AppSpacing.gapLg,
        AuthPhoneField(
          label: null,
          initialDigits: state.draft.phoneNumber,
          errorText: state.phoneError,
          textInputAction: TextInputAction.done,
          onChanged: (digits) =>
              bloc.add(AuthDraftChanged(phoneNumber: digits)),
        ),
      ],
    );
  }
}

class _SecurityStep extends StatelessWidget {
  const _SecurityStep({required this.draft});

  final AuthDraft draft;

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<AuthBloc>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AuthPasswordField(
          label: null,
          hint: 'Create a password',
          initialValue: draft.password,
          onChanged: (value) => bloc.add(AuthDraftChanged(password: value)),
        ),
        // Helper line tucked under the field, then room before the terms.
        AppSpacing.gapSm,
        Padding(
          padding: const EdgeInsets.only(left: AppSpacing.xs),
          child: _PasswordRule(met: draft.hasStrongPassword),
        ),
        AppSpacing.gapLg,
        _TermsCheckbox(
          value: draft.acceptedTerms,
          onChanged: (value) =>
              bloc.add(AuthDraftChanged(acceptedTerms: value)),
        ),
      ],
    );
  }
}

/// "8+ characters, with a letter and a number", ticked once met.
class _PasswordRule extends StatelessWidget {
  const _PasswordRule({required this.met});

  final bool met;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          met ? Icons.check_circle : Icons.check_circle_outline,
          size: AppSizes.iconSm,
          color: met ? AppColors.crimson : AppColors.gray,
        ),
        AppSpacing.gapXs,
        Text(
          '8+ characters, with a letter and a number',
          style: AppTextStyles.caption.copyWith(
            color: met ? AppColors.ink : AppColors.gray,
          ),
        ),
      ],
    );
  }
}

class _TermsCheckbox extends StatelessWidget {
  const _TermsCheckbox({required this.value, required this.onChanged});

  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final link = AppTextStyles.body.copyWith(
      color: AppColors.ink,
      fontWeight: FontWeight.w600,
    );
    return InkWell(
      onTap: () => onChanged(!value),
      borderRadius: AppRadius.smAll,
      child: Row(
        children: [
          // Compact box, like "Remember me" on sign in.
          Theme(
            data: Theme.of(context).copyWith(
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              visualDensity: VisualDensity.compact,
            ),
            child: EdsCheckbox(value: value, onChanged: onChanged),
          ),
          Expanded(
            child: Text.rich(
              TextSpan(
                text: 'I agree to the ',
                children: [
                  TextSpan(text: 'Terms', style: link),
                  const TextSpan(text: ' & '),
                  TextSpan(text: 'Privacy Policy', style: link),
                ],
              ),
              style: AppTextStyles.bodySecondary,
            ),
          ),
        ],
      ),
    );
  }
}
