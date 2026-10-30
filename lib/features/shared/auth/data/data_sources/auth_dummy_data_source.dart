import '../../../../../core/core.dart';
import '../dto/auth_draft_dto.dart';
import '../dto/auth_session_dto.dart';
import '../dto/otp_info_dto.dart';
import '../dto/phone_login_dto.dart';
import '../dto/register_request_dto.dart';
import '../dto/registration_dto.dart';
import 'auth_data_source.dart';

/// Offline stand-in that mirrors the API's JSON and error codes.
///
/// Like the dev environment, the only valid codes are `123456` (sign up /
/// email) and `111111` (phone login); any other code fails with
/// `otp_invalid`, and the third failure locks with `otp_locked`.
///
/// Login returns the role named in the email's local part
/// (`admin@…`, `rider.ali@…`, `retailer1@…`), otherwise customer. Phone
/// logins and fresh sign-ups use the registered role or customer.
class AuthDummyDataSource implements AuthDataSource {
  static const validEmailCode = '123456';
  static const validPhoneCode = '111111';
  static const maxAttempts = 3;

  int _failedAttempts = 0;
  String? _registeredRole;

  @override
  Future<AuthDraftDto?> fetchPrefill() async => AuthDraftDto.fromJson(const {
    'firstName': 'Ayesha',
    'lastName': 'Khan',
    'email': 'admin@gmail.com',
    'password': 'shahryar@123',
    'phoneNumber': '3001234567',
    'acceptedTerms': true,
  });

  @override
  Future<AuthSessionDto> login({
    required String email,
    required String password,
  }) async {
    await dummyDelay();
    return AuthSessionDto.fromJson(_session(_roleFor(email)));
  }

  @override
  Future<PhoneLoginDto> phoneLogin({
    required String phoneCountryCode,
    required String phoneNumber,
    String? password,
  }) async {
    await dummyDelay();
    if (password != null) {
      return PhoneLoginDto.session(
        AuthSessionDto.fromJson(
          _session(_registeredRole ?? AppRole.customer.apiValue),
        ),
      );
    }
    if (_failedAttempts >= maxAttempts) throw _locked();
    return PhoneLoginDto.otp(
      OtpInfoDto.fromJson(_otp('$phoneCountryCode $phoneNumber')),
    );
  }

  @override
  Future<RegistrationDto> register(RegisterRequestDto request) async {
    await dummyDelay();
    _failedAttempts = 0;
    _registeredRole = request.role;
    return RegistrationDto.fromJson({
      'userId': 101,
      'email': request.email,
      'role': request.role,
      'onboardingStatus': 'pending_verification',
      'username': request.email.split('@').first,
      'otp': _otp(request.email),
    });
  }

  @override
  Future<AuthSessionDto> verifyEmailOtp({
    required String email,
    required String code,
  }) => _verify(code, validEmailCode, _registeredRole ?? _roleFor(email));

  @override
  Future<AuthSessionDto> verifyPhoneOtp({
    required String phoneCountryCode,
    required String phoneNumber,
    required String code,
  }) => _verify(
    code,
    validPhoneCode,
    _registeredRole ?? AppRole.customer.apiValue,
  );

  @override
  Future<OtpInfoDto> resendOtp({required String email, String? role}) async {
    await dummyDelay();
    if (_failedAttempts >= maxAttempts) throw _locked();
    return OtpInfoDto.fromJson(_otp(email));
  }

  @override
  Future<Json> fetchProfile() async => const {
    'phoneNumber': '3001234567',
    'email': 'ayesha.k@example.com',
  };

  /// The retailer dummy store serves the shop itself.
  @override
  Future<Json?> fetchStore() async => null;

  @override
  Future<OtpInfoDto> sendPhoneOtp() async {
    await dummyDelay();
    return OtpInfoDto.fromJson(_otp('your phone'));
  }

  @override
  Future<Json> verifyPhone(String code) async {
    await dummyDelay();
    if (code != validEmailCode) {
      throw const ApiException(
        status: 400,
        code: ApiErrorCode.otpInvalid,
        message: 'That code isn’t correct.',
      );
    }
    return const {};
  }

  @override
  Future<void> logout() => dummyDelay();

  @override
  Future<void> deleteAccount(String password) async {
    await dummyDelay();
    if (password.trim().isEmpty) {
      throw const ApiException(
        status: 403,
        code: ApiErrorCode.invalidCredentials,
        message: 'Enter your password to confirm.',
      );
    }
  }

  Future<AuthSessionDto> _verify(
    String code,
    String validCode,
    String role,
  ) async {
    await dummyDelay();
    if (_failedAttempts >= maxAttempts) throw _locked();
    if (code != validCode) {
      _failedAttempts++;
      if (_failedAttempts >= maxAttempts) throw _locked();
      throw const ApiException(
        status: 401,
        code: ApiErrorCode.otpInvalid,
        message: 'That code isn’t correct.',
      );
    }
    _failedAttempts = 0;
    return AuthSessionDto.fromJson(_session(role));
  }

  String _roleFor(String email) {
    final name = email.split('@').first.toLowerCase();
    return AppRole.values
        .firstWhere(
          (r) => name.contains(r.apiValue),
          orElse: () => AppRole.customer,
        )
        .apiValue;
  }

  Json _session(String role) => {
    'accessToken': 'dummy-access-token',
    'tokenType': 'bearer',
    'expiresIn': 900,
    'refreshToken': 'dummy-refresh-token',
    'refreshExpiresIn': 2592000,
    'role': role,
    'user': {'id': 101, 'role': role},
  };

  Json _otp(String sentTo) {
    final now = DateTime.now().toUtc();
    return {
      'sentTo': sentTo,
      'expiresAt': now.add(const Duration(minutes: 10)).toIso8601String(),
      'resendAvailableAt': now
          .add(const Duration(seconds: 28))
          .toIso8601String(),
      'length': 6,
    };
  }

  ApiException _locked() => const ApiException(
    status: 429,
    code: ApiErrorCode.otpLocked,
    message: 'Too many attempts. Try again later.',
  );
}
