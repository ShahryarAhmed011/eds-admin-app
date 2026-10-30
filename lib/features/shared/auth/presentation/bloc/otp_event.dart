part of 'otp_bloc.dart';

sealed class OtpEvent extends Equatable {
  const OtpEvent();

  @override
  List<Object?> get props => [];
}

final class OtpStarted extends OtpEvent {
  const OtpStarted();
}

final class OtpCodeChanged extends OtpEvent {
  const OtpCodeChanged(this.code);

  final String code;

  @override
  List<Object?> get props => [code];
}

final class OtpVerifyRequested extends OtpEvent {
  const OtpVerifyRequested();
}

final class OtpResendRequested extends OtpEvent {
  const OtpResendRequested();
}

final class _OtpTicked extends OtpEvent {
  const _OtpTicked();
}
