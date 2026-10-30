part of 'otp_bloc.dart';

enum OtpStatus { entry, incorrect, expired, locked }

sealed class OtpState extends Equatable {
  const OtpState();

  @override
  List<Object?> get props => [];
}

final class OtpLoading extends OtpState {
  const OtpLoading();
}

final class OtpReady extends OtpState {
  const OtpReady({
    required this.challenge,
    required this.now,
    this.code = '',
    this.status = OtpStatus.entry,
    this.failedAttempts = 0,
    this.lockedUntil,
    this.isVerifying = false,
    this.isResending = false,
    this.signedIn,
    this.message,
  });

  final OtpChallenge challenge;

  /// Clock reading used for the countdowns.
  final DateTime now;
  final String code;
  final OtpStatus status;
  final int failedAttempts;
  final DateTime? lockedUntil;
  final bool isVerifying;
  final bool isResending;

  /// One-shot: verification succeeded.
  final SignedInUser? signedIn;

  /// One-shot snackbar text.
  final String? message;

  int get attemptsRemaining =>
      (OtpBloc.maxAttempts - failedAttempts).clamp(0, OtpBloc.maxAttempts);

  /// Time until "Resend code" is allowed, or null when it already is.
  Duration? get resendIn => _until(challenge.resendAvailableAt);

  /// Time left on a lock, or null when not locked / unknown.
  Duration? get lockRemaining => _until(lockedUntil);

  bool get hasCountdown => resendIn != null || lockRemaining != null;

  bool get canVerify =>
      status != OtpStatus.locked &&
      !isVerifying &&
      code.length == challenge.length;

  bool get canResend =>
      status != OtpStatus.locked && !isResending && resendIn == null;

  Duration? _until(DateTime? at) {
    if (at == null) return null;
    final left = at.difference(now);
    return left > Duration.zero ? left : null;
  }

  OtpReady copyWith({
    DateTime? now,
    String? code,
    OtpStatus? status,
    int? failedAttempts,
    DateTime? lockedUntil,
    bool isVerifying = false,
    bool isResending = false,
    SignedInUser? signedIn,
    String? message,
    bool clearMessage = false,
  }) => OtpReady(
    challenge: challenge,
    now: now ?? this.now,
    code: code ?? this.code,
    status: status ?? this.status,
    failedAttempts: failedAttempts ?? this.failedAttempts,
    lockedUntil: lockedUntil ?? this.lockedUntil,
    isVerifying: isVerifying,
    isResending: isResending,
    signedIn: signedIn,
    message: clearMessage ? null : message,
  );

  @override
  List<Object?> get props => [
    challenge,
    now,
    code,
    status,
    failedAttempts,
    lockedUntil,
    isVerifying,
    isResending,
    signedIn,
    message,
  ];
}

final class OtpFailure extends OtpState {
  const OtpFailure(this.message, {this.reference});

  final String message;
  final String? reference;

  @override
  List<Object?> get props => [message, reference];
}
