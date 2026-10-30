import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/core.dart';
import '../../../../../core/di/injection.dart';
import '../../../common/phone_number.dart';
import '../../domain/entities/otp_challenge.dart';
import '../sign_out.dart';
import '../bloc/otp_bloc.dart';

/// "OTP verification" for a phone login or a sign-up email. Incorrect,
/// expired and locked states come from the API's error codes. Verifies as
/// soon as the last digit is typed; the Verify button is the fallback.
class OtpScreen extends StatelessWidget {
  const OtpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<OtpBloc>()..add(const OtpStarted()),
      child: const _OtpView(),
    );
  }
}

class _OtpView extends StatelessWidget {
  const _OtpView();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<OtpBloc, OtpState>(
      listenWhen: (_, current) =>
          current is OtpReady &&
          (current.signedIn != null || current.message != null),
      listener: (context, state) {
        final ready = state as OtpReady;
        if (ready.signedIn case final user?) {
          context.go(user.role.homeRoute);
        } else if (ready.message case final message?) {
          EdsToast.of(context).show(message);
        }
      },
      builder: (context, state) => PopScope(
        // Verifying the account's phone: back signs out (see
        // _changeDestination) instead of returning into the app.
        canPop: !(state is OtpReady && state.challenge.verifiesAccount),
        onPopInvokedWithResult: (didPop, _) {
          if (!didPop && state is OtpReady) {
            _changeDestination(context, state.challenge);
          }
        },
        child: AnnotatedRegion<SystemUiOverlayStyle>(
          // Light status bar icons over the crimson header.
          value: state is OtpReady
              ? SystemUiOverlayStyle.light
              : SystemUiOverlayStyle.dark,
          child: Scaffold(
            body: switch (state) {
              OtpLoading() => const EdsLoadingView(),
              OtpFailure(:final message, :final reference) => SafeArea(
                child: EdsErrorView(
                  message: message,
                  reference: reference,
                  onRetry: () =>
                      context.read<OtpBloc>().add(const OtpStarted()),
                ),
              ),
              // Read above the Scaffold: it hides the keyboard inset from
              // its body.
              OtpReady() => _OtpContent(
                state,
                keyboardOpen: MediaQuery.viewInsetsOf(context).bottom > 0,
              ),
            },
          ),
        ),
      ),
    );
  }
}

class _OtpContent extends StatelessWidget {
  const _OtpContent(this.state, {required this.keyboardOpen});

  final OtpReady state;
  final bool keyboardOpen;

  @override
  Widget build(BuildContext context) {
    final challenge = state.challenge;
    final locked = state.status == OtpStatus.locked;
    // Crimson behind everything so the sheet's rounded corners show it.
    return ColoredBox(
      color: AppColors.crimson,
      child: CustomScrollView(
        slivers: [
          SliverFillRemaining(
            hasScrollBody: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _OtpHeader(
                  challenge: challenge,
                  locked: locked,
                  keyboardOpen: keyboardOpen,
                ),
                Expanded(child: _OtpSheet(state)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Crimson header: back button, an icon, the title in the sign-in
/// heading's style and where the code went. Covers the top half of the
/// screen; collapses to its content while the keyboard is open so the code
/// boxes stay in view.
class _OtpHeader extends StatelessWidget {
  const _OtpHeader({
    required this.challenge,
    required this.locked,
    required this.keyboardOpen,
  });

  static const _screenFraction = 0.5;
  static const _iconSize = 64.0;

  final OtpChallenge challenge;
  final bool locked;
  final bool keyboardOpen;

  @override
  Widget build(BuildContext context) {
    final height = keyboardOpen
        ? null
        : MediaQuery.sizeOf(context).height * _screenFraction;
    final onCrimson = AppColors.onCrimsonMuted;

    return AnimatedSize(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
      alignment: Alignment.topCenter,
      child: SizedBox(
        height: height,
        child: SafeArea(
          bottom: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.xs),
                  child: IconButton(
                    tooltip: challenge.verifiesAccount
                        ? 'Back to log in'
                        : 'Back',
                    color: AppColors.white,
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => _changeDestination(context, challenge),
                  ),
                ),
              ),
              if (height != null) const Spacer(),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (!keyboardOpen) ...[
                      Container(
                        width: _iconSize,
                        height: _iconSize,
                        decoration: BoxDecoration(
                          color: AppColors.onCrimsonTint,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          locked
                              ? Icons.lock_clock_outlined
                              : challenge.isPhone
                              ? Icons.sms_outlined
                              : Icons.mark_email_read_outlined,
                          color: AppColors.white,
                          size: 30,
                        ),
                      ),
                      AppSpacing.gapLg,
                    ],
                    Text(
                      locked ? 'Try again later' : 'Verify your identity',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.headline.copyWith(
                        color: AppColors.white,
                      ),
                    ),
                    AppSpacing.gapSm,
                    Text(
                      'Enter the ${challenge.length}-digit code we sent to',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.bodyLarge.copyWith(color: onCrimson),
                    ),
                    AppSpacing.gapXs,
                    _SentTo(challenge),
                  ],
                ),
              ),
              if (height != null) const Spacer(),
              AppSpacing.gapXl,
            ],
          ),
        ),
      ),
    );
  }
}

/// White sheet whose rounded top corners show the crimson behind: code
/// boxes, resend line and Verify, with the safety note at the bottom.
class _OtpSheet extends StatelessWidget {
  const _OtpSheet(this.state);

  final OtpReady state;

  @override
  Widget build(BuildContext context) {
    final challenge = state.challenge;
    final locked = state.status == OtpStatus.locked;
    final bloc = context.read<OtpBloc>();
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppRadius.sheet),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.xxxl,
            AppSpacing.lg,
            AppSpacing.lg,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              EdsOtpField(
                // A new key resets the boxes when the state or code
                // changes.
                key: ValueKey((
                  state.status,
                  state.failedAttempts,
                  challenge.resendAvailableAt,
                )),
                length: challenge.length,
                initialValue: state.code,
                hasError: state.status == OtpStatus.incorrect,
                enabled: !locked,
                autofocus: !locked,
                onChanged: (code) => bloc.add(OtpCodeChanged(code)),
                onCompleted: (_) => bloc.add(const OtpVerifyRequested()),
              ),
              AppSpacing.gapLg,
              _OtpStatusLine(state),
              AppSpacing.gapXxl,
              locked
                  ? EdsButton.secondary(
                      label: 'Back to log in',
                      onPressed: () => context.go(AppRoutes.signIn),
                    )
                  : EdsButton.primary(
                      label: 'Verify',
                      isLoading: state.isVerifying,
                      onPressed: state.canVerify
                          ? () => bloc.add(const OtpVerifyRequested())
                          : null,
                    ),
              const Spacer(),
              AppSpacing.gapXl,
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.lock_outline,
                    size: 14,
                    color: AppColors.gray,
                  ),
                  AppSpacing.gapXs,
                  Flexible(
                    child: Text(
                      'EDoorStep will never ask you for this code.',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.caption,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Back / "Change": return to the form that sent the code.
void _changeDestination(BuildContext context, OtpChallenge challenge) {
  // Verifying the signed-in account's phone or email: the router keeps a
  // signed-in user on this step, so going back means signing out to log in
  // again.
  if (challenge.verifiesAccount) {
    signOutToLogIn(context);
    return;
  }
  if (context.canPop()) {
    context.pop();
  } else {
    context.go(challenge.isPhone ? AppRoutes.signIn : AppRoutes.signUp);
  }
}

/// "**+92 300-1234567** · Change", White on the crimson header.
class _SentTo extends StatelessWidget {
  const _SentTo(this.challenge);

  final OtpChallenge challenge;

  @override
  Widget build(BuildContext context) {
    final destination = switch (challenge.phoneNumber) {
      final phone? => PhoneNumber.format(PhoneNumber.countryCode, phone),
      null => challenge.sentTo,
    };
    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: AppSpacing.xs,
      children: [
        Text(
          destination,
          style: AppTextStyles.itemTitleLarge.copyWith(color: AppColors.white),
        ),
        if (!challenge.verifiesAccount)
          TextButton(
            onPressed: () => _changeDestination(context, challenge),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.white,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
              minimumSize: const Size(0, 36),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              'Change',
              style: AppTextStyles.link.copyWith(
                color: AppColors.white,
                decoration: TextDecoration.underline,
                decorationColor: AppColors.white,
              ),
            ),
          ),
      ],
    );
  }
}

/// One line under the boxes: resend countdown / action, or what went wrong.
class _OtpStatusLine extends StatelessWidget {
  const _OtpStatusLine(this.state);

  final OtpReady state;

  @override
  Widget build(BuildContext context) {
    final channel = state.challenge.isPhone ? 'SMS' : 'email';
    return switch (state.status) {
      OtpStatus.locked => EdsBanner(
        tone: EdsTone.danger,
        title: 'Too many attempts',
        message: switch (state.lockRemaining) {
          final left? =>
            'For your security, verification is paused. Try again in '
                '${_mmss(left)}. Your account is safe.',
          null =>
            'For your security, verification is paused. '
                'Your account is safe.',
        },
      ),
      OtpStatus.incorrect => Column(
        children: [
          _Problem(
            state.attemptsRemaining > 0
                ? 'That code isn’t correct · ${state.attemptsRemaining} '
                      '${state.attemptsRemaining == 1 ? 'attempt' : 'attempts'}'
                      ' left'
                : 'That code isn’t correct',
          ),
          AppSpacing.gapSm,
          _ResendAction(state, channel: channel),
        ],
      ),
      OtpStatus.expired => Column(
        children: [
          const _Problem('That code has expired'),
          AppSpacing.gapSm,
          _ResendAction(state, channel: channel),
        ],
      ),
      OtpStatus.entry => _ResendAction(state, channel: channel),
    };
  }
}

/// Ink error text with an icon — errors never use a red.
class _Problem extends StatelessWidget {
  const _Problem(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.error_outline, size: AppSizes.iconSm),
        AppSpacing.gapXs,
        Flexible(
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: AppTextStyles.itemTitle,
          ),
        ),
      ],
    );
  }
}

class _ResendAction extends StatelessWidget {
  const _ResendAction(this.state, {required this.channel});

  final OtpReady state;
  final String channel;

  @override
  Widget build(BuildContext context) {
    if (state.resendIn case final left?) {
      return Text.rich(
        TextSpan(
          text: 'Didn’t get the code? Resend $channel in ',
          children: [
            TextSpan(
              text: _mmss(left),
              style: AppTextStyles.body.copyWith(
                color: AppColors.ink,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        textAlign: TextAlign.center,
        style: AppTextStyles.bodySecondary,
      );
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('Didn’t get the code?', style: AppTextStyles.bodySecondary),
        AppSpacing.gapXs,
        EdsButton.text(
          label: state.isResending ? 'Sending…' : 'Resend $channel',
          onPressed: state.canResend
              ? () => context.read<OtpBloc>().add(const OtpResendRequested())
              : null,
        ),
      ],
    );
  }
}

String _mmss(Duration d) {
  final seconds = d.inSeconds + (d.inMilliseconds % 1000 > 0 ? 1 : 0);
  return '${(seconds ~/ 60).toString().padLeft(2, '0')}:'
      '${(seconds % 60).toString().padLeft(2, '0')}';
}
