import '../../../../../core/core.dart';
import 'otp_info_dto.dart';

/// `data` of `POST /auth/login`, `/auth/signup`, `/auth/otp/verify`,
/// `/auth/phone/verify` and `/auth/refresh`.
class AuthSessionDto {
  const AuthSessionDto({
    required this.accessToken,
    required this.refreshToken,
    required this.role,
    this.tokenType,
    this.expiresIn,
    this.refreshExpiresIn,
    this.status,
    this.user,
    this.otp,
  });

  factory AuthSessionDto.fromJson(Json json) => AuthSessionDto(
    accessToken: json.strOr('accessToken'),
    refreshToken: json.strOr('refreshToken'),
    role: json.strOr('role', AppRole.customer.apiValue),
    tokenType: json.str('tokenType'),
    expiresIn: json.integer('expiresIn'),
    refreshExpiresIn: json.integer('refreshExpiresIn'),
    user: json.obj('user'),
    otp: switch (json.obj('otp')) {
      final otp? => OtpInfoDto.fromJson(otp),
      null => null,
    },
    status: switch (json.obj('status')) {
      final status? => OnboardingStatus.fromJson(status),
      null => null,
    },
  );

  /// Whether [json] carries a session (tokens), e.g. a sign up response.
  static bool hasSession(Json json) => json.str('accessToken') != null;

  final String accessToken;
  final String refreshToken;
  final String role;
  final String? tokenType;
  final int? expiresIn;
  final int? refreshExpiresIn;

  /// The account's onboarding progress (`isPhoneVerified`, …), when sent.
  final OnboardingStatus? status;

  /// The account (`id`, `email`, `firstName`, `lastName`, …), when sent.
  final Json? user;

  /// The code the API just sent (masked `sentTo`, timers), when it sent
  /// one: for the channel the account verifies first.
  final OtpInfoDto? otp;
}
