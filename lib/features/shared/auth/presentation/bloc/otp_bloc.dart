import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/core.dart';
import '../../domain/entities/otp_challenge.dart';
import '../../domain/entities/signed_in_user.dart';
import '../../domain/usecase/get_pending_verification.dart';
import '../../domain/usecase/resend_otp.dart';
import '../../domain/usecase/verify_otp.dart';

part 'otp_event.dart';
part 'otp_state.dart';

/// Drives the OTP screen through its entry, incorrect, expired and locked
/// states. Ticks once a second while a countdown is visible.
class OtpBloc extends Bloc<OtpEvent, OtpState> {
  OtpBloc(this._getPending, this._verifyOtp, this._resendOtp, {this.clock})
    : super(const OtpLoading()) {
    on<OtpStarted>(_onStarted);
    on<OtpCodeChanged>(_onCodeChanged);
    on<OtpVerifyRequested>(_onVerifyRequested);
    on<OtpResendRequested>(_onResendRequested);
    on<_OtpTicked>(_onTicked);
  }

  /// The API doesn't say how long a lock lasts; the design shows 15 min.
  static const lockDuration = Duration(minutes: 15);

  /// Client-side budget used for "N attempts remaining".
  static const maxAttempts = 3;

  final GetPendingVerification _getPending;
  final VerifyOtp _verifyOtp;
  final ResendOtp _resendOtp;

  /// Injectable for tests.
  final DateTime Function()? clock;

  Timer? _ticker;

  DateTime _now() => (clock ?? DateTime.now)();

  Future<void> _onStarted(OtpStarted event, Emitter<OtpState> emit) async {
    emit(const OtpLoading());
    try {
      final challenge = await _getPending(const NoParams());
      emit(OtpReady(challenge: challenge, now: _now()));
      _ticker ??= Timer.periodic(
        const Duration(seconds: 1),
        (_) => add(const _OtpTicked()),
      );
    } catch (e) {
      emit(OtpFailure(errorMessage(e), reference: errorReference(e)));
    }
  }

  void _onTicked(_OtpTicked event, Emitter<OtpState> emit) {
    final current = state;
    if (current is OtpReady && current.hasCountdown) {
      emit(current.copyWith(now: _now()));
    }
  }

  void _onCodeChanged(OtpCodeChanged event, Emitter<OtpState> emit) {
    final current = state;
    if (current is! OtpReady || current.status == OtpStatus.locked) return;
    emit(current.copyWith(code: event.code));
  }

  Future<void> _onVerifyRequested(
    OtpVerifyRequested event,
    Emitter<OtpState> emit,
  ) async {
    final current = state;
    if (current is! OtpReady || !current.canVerify) return;
    emit(current.copyWith(isVerifying: true));
    try {
      final user = await _verifyOtp(current.code);
      emit(current.copyWith(signedIn: user));
      emit(current);
    } on ApiException catch (e) {
      emit(_applyError(current, e));
      emit(_applyError(current, e).copyWith(clearMessage: true));
    } catch (e) {
      emit(current.copyWith(message: errorMessage(e)));
      emit(current);
    }
  }

  Future<void> _onResendRequested(
    OtpResendRequested event,
    Emitter<OtpState> emit,
  ) async {
    final current = state;
    if (current is! OtpReady || !current.canResend) return;
    emit(current.copyWith(isResending: true));
    try {
      final challenge = await _resendOtp(const NoParams());
      emit(
        OtpReady(
          challenge: challenge,
          now: _now(),
          failedAttempts: current.failedAttempts,
          message: 'A new code is on its way to ${challenge.sentTo}.',
        ),
      );
      emit((state as OtpReady).copyWith(clearMessage: true));
    } on ApiException catch (e) {
      emit(_applyError(current, e));
      emit(_applyError(current, e).copyWith(clearMessage: true));
    } catch (e) {
      emit(current.copyWith(message: errorMessage(e)));
      emit(current);
    }
  }

  /// Maps API error codes to the screen's states. Never reads `message`
  /// for branching; unknown errors keep the state and show a snackbar.
  OtpReady _applyError(OtpReady current, ApiException e) => switch (e.code) {
    // Clear the wrong code so the boxes are ready for another try.
    ApiErrorCode.otpInvalid => current.copyWith(
      code: '',
      status: OtpStatus.incorrect,
      failedAttempts: current.failedAttempts + 1,
    ),
    ApiErrorCode.otpExpired => current.copyWith(status: OtpStatus.expired),
    ApiErrorCode.otpLocked => current.copyWith(
      status: OtpStatus.locked,
      lockedUntil: _now().add(lockDuration),
      now: _now(),
    ),
    _ => current.copyWith(message: errorMessage(e)),
  };

  @override
  Future<void> close() {
    _ticker?.cancel();
    return super.close();
  }
}
