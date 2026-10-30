import '../../../../../core/core.dart';
import 'auth_session_dto.dart';
import 'otp_info_dto.dart';

/// `data` of `POST /auth/signup`.
class RegistrationDto {
  const RegistrationDto({
    required this.userId,
    required this.email,
    required this.role,
    this.onboardingStatus,
    this.username,
    this.otp,
    this.session,
  });

  factory RegistrationDto.fromJson(Json json) => RegistrationDto(
    userId: json.id('userId'),
    email: json.strOr('email'),
    role: json.strOr('role', AppRole.customer.apiValue),
    onboardingStatus: json.str('onboardingStatus'),
    username: json.str('username'),
    otp: switch (json.obj('otp')) {
      final otp? => OtpInfoDto.fromJson(otp),
      null => null,
    },
    session: AuthSessionDto.hasSession(json)
        ? AuthSessionDto.fromJson(json)
        : null,
  );

  final String userId;
  final String email;
  final String role;
  final String? onboardingStatus;
  final String? username;

  /// The code that was sent: the phone code when a [session] is included,
  /// otherwise the email code.
  final OtpInfoDto? otp;

  /// Sign up now signs in: tokens and onboarding status.
  final AuthSessionDto? session;
}
