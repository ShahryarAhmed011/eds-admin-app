import '../../../../../core/core.dart';
import '../dto/auth_draft_dto.dart';
import '../dto/auth_session_dto.dart';
import '../dto/otp_info_dto.dart';
import '../dto/phone_login_dto.dart';
import '../dto/register_request_dto.dart';
import '../dto/registration_dto.dart';

/// Auth endpoints. `role` is an `AppRole.apiValue`; it is only sent where
/// the API takes it (register, and resend when known).
abstract interface class AuthDataSource {
  /// Sample form values; null when there's nothing to prefill.
  Future<AuthDraftDto?> fetchPrefill();

  /// `POST /auth/login` with `login_type: email`. The response's `role`
  /// decides where the app goes.
  Future<AuthSessionDto> login({
    required String email,
    required String password,
  });

  /// `POST /auth/login` with `login_type: phone`. With [password]: tokens
  /// (phone + password login). Without: sends a code, no tokens.
  Future<PhoneLoginDto> phoneLogin({
    required String phoneCountryCode,
    required String phoneNumber,
    String? password,
  });

  /// `POST /auth/signup` (role required). Signs in and sends a code for
  /// the contact verified first (`otp.sentTo` says which).
  Future<RegistrationDto> register(RegisterRequestDto request);

  /// `POST /auth/phone/send-otp`: a new code to the signed-in account's
  /// phone.
  Future<OtpInfoDto> sendPhoneOtp();

  /// `GET /profile` for the signed-in account (its `data`).
  Future<Json> fetchProfile();

  /// `GET /store` for a retailer: its data, or null when there is no store
  /// yet (404).
  Future<Json?> fetchStore();

  /// `POST /auth/phone/verify`: verifies the signed-in account's phone.
  /// Returns the response `data` (may carry a fresh `status` or tokens).
  Future<Json> verifyPhone(String code);

  /// `POST /auth/otp/verify` for a sign-up / email code.
  Future<AuthSessionDto> verifyEmailOtp({
    required String email,
    required String code,
  });

  /// `POST /auth/otp/verify` for a phone login code.
  Future<AuthSessionDto> verifyPhoneOtp({
    required String phoneCountryCode,
    required String phoneNumber,
    required String code,
  });

  /// `POST /auth/otp/resend` for a sign-up / email code.
  Future<OtpInfoDto> resendOtp({required String email, String? role});

  /// `POST /auth/logout`. Signs out every device.
  Future<void> logout();

  /// `DELETE /account` for the signed-in user; the current [password]
  /// re-confirms. `403 invalid_credentials` on a wrong password, and
  /// nothing is deleted.
  Future<void> deleteAccount(String password);
}
