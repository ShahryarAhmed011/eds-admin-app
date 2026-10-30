import '../../../../../core/core.dart';
import 'auth_session_dto.dart';
import 'otp_info_dto.dart';

/// `data` of a phone `POST /auth/login`: tokens when a password was sent
/// and accepted, otherwise the code that was sent.
class PhoneLoginDto {
  const PhoneLoginDto.session(AuthSessionDto this.session) : otp = null;
  const PhoneLoginDto.otp(OtpInfoDto this.otp) : session = null;

  /// Decides by the presence of `access_token`, so a server that doesn't
  /// support password login yet (and sends a code) still works.
  factory PhoneLoginDto.fromResponse(Json json) =>
      AuthSessionDto.hasSession(json)
      ? PhoneLoginDto.session(AuthSessionDto.fromJson(json))
      : PhoneLoginDto.otp(OtpInfoDto.fromResponse(json));

  final AuthSessionDto? session;
  final OtpInfoDto? otp;
}
