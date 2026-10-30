import '../../../../../core/core.dart';
import '../dto/auth_draft_dto.dart';
import '../dto/auth_session_dto.dart';
import '../dto/otp_info_dto.dart';
import '../dto/phone_login_dto.dart';
import '../dto/register_request_dto.dart';
import '../dto/registration_dto.dart';
import 'auth_data_source.dart';

class AuthRemoteDataSource implements AuthDataSource {
  const AuthRemoteDataSource(this._api);

  final ApiClient _api;

  /// Admin account filled into the login form in debug and release builds.
  @override
  Future<AuthDraftDto?> fetchPrefill() async => AuthDraftDto.fromJson(const {
    'email': 'admin@gmail.com',
    'password': 'shahryar@123',
  });

  @override
  Future<AuthSessionDto> login({
    required String email,
    required String password,
  }) async => AuthSessionDto.fromJson(
    _json(
      await _api.post(
        '/auth/login',
        body: {'loginType': 'email', 'email': email, 'password': password},
      ),
    ),
  );

  @override
  Future<PhoneLoginDto> phoneLogin({
    required String phoneCountryCode,
    required String phoneNumber,
    String? password,
  }) async => PhoneLoginDto.fromResponse(
    _json(
      await _api.post(
        '/auth/login',
        body: {
          'loginType': 'phone',
          'phoneCountryCode': phoneCountryCode,
          'phoneNumber': phoneNumber,
          'password': ?password,
        },
      ),
    ),
  );

  @override
  Future<RegistrationDto> register(RegisterRequestDto request) async =>
      RegistrationDto.fromJson(
        _json(await _api.post('/auth/signup', body: request.toJson())),
      );

  @override
  Future<AuthSessionDto> verifyEmailOtp({
    required String email,
    required String code,
  }) async => AuthSessionDto.fromJson(
    _json(
      await _api.post('/auth/otp/verify', body: {'email': email, 'code': code}),
    ),
  );

  @override
  Future<AuthSessionDto> verifyPhoneOtp({
    required String phoneCountryCode,
    required String phoneNumber,
    required String code,
  }) async => AuthSessionDto.fromJson(
    _json(
      await _api.post(
        '/auth/otp/verify',
        body: {
          'phoneCountryCode': phoneCountryCode,
          'phoneNumber': phoneNumber,
          'code': code,
        },
      ),
    ),
  );

  @override
  Future<OtpInfoDto> resendOtp({required String email, String? role}) async =>
      OtpInfoDto.fromResponse(
        _json(
          await _api.post(
            '/auth/otp/resend',
            body: {'email': email, 'role': ?role},
          ),
        ),
      );

  @override
  Future<Json> fetchProfile() => _api.getObject('/profile');

  @override
  Future<Json?> fetchStore() async {
    try {
      return await _api.getObject('/store');
    } on ApiException catch (e) {
      if (e.status == 404) return null;
      rethrow;
    }
  }

  @override
  Future<OtpInfoDto> sendPhoneOtp() async =>
      OtpInfoDto.fromResponse(_json(await _api.post('/auth/phone/send-otp')));

  @override
  Future<Json> verifyPhone(String code) async =>
      _json(await _api.post('/auth/phone/verify', body: {'code': code}));

  @override
  Future<void> logout() => _api.post('/auth/logout');

  @override
  Future<void> deleteAccount(String password) =>
      _api.delete('/account', body: {'password': password});

  Json _json(dynamic data) =>
      data is Map ? data.cast<String, dynamic>() : <String, dynamic>{};
}
