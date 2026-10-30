import 'package:eds_admin_app/core/core.dart';
import 'package:eds_admin_app/features/shared/auth/data/data_sources/auth_dummy_data_source.dart';
import 'package:eds_admin_app/features/shared/auth/data/data_sources/remembered_login_storage.dart';
import 'package:eds_admin_app/features/shared/auth/data/dto/auth_draft_dto.dart';
import 'package:eds_admin_app/features/shared/auth/data/dto/auth_session_dto.dart';
import 'package:eds_admin_app/features/shared/auth/data/dto/otp_info_dto.dart';
import 'package:eds_admin_app/features/shared/auth/data/dto/phone_login_dto.dart';
import 'package:eds_admin_app/features/shared/auth/data/dto/register_request_dto.dart';
import 'package:eds_admin_app/features/shared/auth/data/dto/registration_dto.dart';
import 'package:eds_admin_app/features/shared/auth/data/repository/auth_repository_impl.dart';
import 'package:eds_admin_app/features/shared/auth/domain/entities/auth_draft.dart';
import 'package:eds_admin_app/features/shared/auth/domain/entities/auth_result.dart';
import 'package:flutter_test/flutter_test.dart';

class _MemoryTokens implements TokenStorage {
  AuthTokens? tokens;

  @override
  Future<AuthTokens?> read() async => tokens;

  @override
  Future<void> write(AuthTokens value) async => tokens = value;

  @override
  Future<void> clear() async => tokens = null;
}

class _MemoryRememberedLogin implements RememberedLoginStorage {
  String? digits;
  String? email;

  @override
  Future<String?> readPhone() async => digits;

  @override
  Future<void> writePhone(String value) async => digits = value;

  @override
  Future<void> clearPhone() async => digits = null;

  @override
  Future<String?> readEmail() async => email;

  @override
  Future<void> writeEmail(String value) async => email = value;

  @override
  Future<void> clearEmail() async => email = null;
}

/// Records which endpoint each repository call reaches.
class _RecordingDataSource extends AuthDummyDataSource {
  final calls = <String>[];

  @override
  Future<AuthDraftDto?> fetchPrefill() async => null;

  @override
  Future<PhoneLoginDto> phoneLogin({
    required String phoneCountryCode,
    required String phoneNumber,
    String? password,
  }) {
    calls.add(
      'login:phone $phoneCountryCode $phoneNumber'
      '${password == null ? '' : ' password:$password'}',
    );
    return super.phoneLogin(
      phoneCountryCode: phoneCountryCode,
      phoneNumber: phoneNumber,
      password: password,
    );
  }

  @override
  Future<AuthSessionDto> verifyEmailOtp({
    required String email,
    required String code,
  }) {
    calls.add('verify:email $email');
    return super.verifyEmailOtp(email: email, code: code);
  }

  @override
  Future<AuthSessionDto> verifyPhoneOtp({
    required String phoneCountryCode,
    required String phoneNumber,
    required String code,
  }) {
    calls.add('verify:phone $phoneCountryCode $phoneNumber');
    return super.verifyPhoneOtp(
      phoneCountryCode: phoneCountryCode,
      phoneNumber: phoneNumber,
      code: code,
    );
  }

  @override
  Future<OtpInfoDto> resendOtp({required String email, String? role}) {
    calls.add('resend $email $role');
    return super.resendOtp(email: email, role: role);
  }

  @override
  Future<RegistrationDto> register(RegisterRequestDto request) {
    calls.add('register ${request.role}');
    return super.register(request);
  }
}

void main() {
  late _RecordingDataSource source;
  late _MemoryTokens tokens;
  late _MemoryRememberedLogin remembered;
  late AuthRepositoryImpl repository;

  setUp(() {
    source = _RecordingDataSource();
    tokens = _MemoryTokens();
    remembered = _MemoryRememberedLogin();
    repository = AuthRepositoryImpl(source, tokens, remembered);
  });

  test('email login takes the role from the response', () async {
    final user = await repository.signIn(
      email: 'rider.ali@example.com',
      password: 'Abcd-1234',
    );
    expect(user.role, AppRole.rider);
    expect(tokens.tokens?.role, 'rider');
  });

  test('phone login: request a code, then verify with the number', () async {
    final result = await repository.loginWithPhone('0300 1234567');
    final challenge = (result as AuthCodeSent).challenge;
    expect(challenge.isPhone, isTrue);
    expect(challenge.phoneNumber, '3001234567');

    final user = await repository.verifyOtp(AuthDummyDataSource.validPhoneCode);

    expect(user.role, AppRole.customer);
    expect(tokens.tokens, isNotNull);
    expect(source.calls, [
      'login:phone +92 3001234567',
      'verify:phone +92 3001234567',
    ]);
  });

  test('phone + password signs in straight away, with no code', () async {
    final result = await repository.loginWithPhone(
      '3001234567',
      password: 'Abcd-1234',
    );
    expect((result as AuthSignedIn).user.role, AppRole.customer);
    expect(tokens.tokens, isNotNull);
    expect(source.calls, ['login:phone +92 3001234567 password:Abcd-1234']);
  });

  test('a server that answers a password login with a code still works', () {
    final response = PhoneLoginDto.fromResponse({
      'otp': {'sentTo': '+92 300*****67', 'length': 6},
    });
    expect(response.session, isNull);
    expect(response.otp?.sentTo, '+92 300*****67');

    final tokens = PhoneLoginDto.fromResponse({
      'accessToken': 'a',
      'refreshToken': 'r',
      'role': 'rider',
    });
    expect(tokens.session?.role, 'rider');
  });

  test('resending a phone code never sends the password', () async {
    await repository.loginWithPhone('3001234567');
    await repository.resendOtp();
    expect(source.calls, [
      'login:phone +92 3001234567',
      'login:phone +92 3001234567',
    ]);
  });

  test('remember me saves the number and pre-fills the next draft', () async {
    await repository.loginWithPhone('0300 1234567', rememberMe: true);
    expect(remembered.digits, '3001234567');

    final draft = await repository.getDraft();
    expect(draft.phoneNumber, '3001234567');
    expect(draft.rememberMe, isTrue);
    expect(draft.password, isEmpty);
  });

  test('remember me on an email login saves the email', () async {
    await repository.signIn(
      email: 'user@example.com',
      password: 'Abcd-1234',
      rememberMe: true,
    );
    expect(remembered.email, 'user@example.com');
    expect((await repository.getDraft()).email, 'user@example.com');

    await repository.signIn(email: 'user@example.com', password: 'Abcd-1234');
    expect(remembered.email, isNull);
  });

  test('logging in without remember me forgets a saved number', () async {
    remembered.digits = '3001234567';
    await repository.loginWithPhone('3001234567');
    expect(remembered.digits, isNull);
  });

  test('a phone code is resent by requesting the login again', () async {
    await repository.loginWithPhone('3001234567');
    await repository.resendOtp();
    expect(source.calls, [
      'login:phone +92 3001234567',
      'login:phone +92 3001234567',
    ]);
  });

  test('sign up verifies by email only and resends with the role', () async {
    await repository.signUp(
      const AuthDraft(
        firstName: 'Ali',
        lastName: 'Khan',
        email: 'user@example.com',
        password: 'Abcd-1234',
        phoneNumber: '3001234567',
        acceptedTerms: true,
      ),
      AppRole.retailer,
    );
    await repository.resendOtp();
    final user = await repository.verifyOtp(AuthDummyDataSource.validEmailCode);

    expect(user.role, AppRole.retailer);
    expect(source.calls, [
      'register retailer',
      'resend user@example.com retailer',
      'verify:email user@example.com',
    ]);
  });

  test('logout clears tokens even if the API call fails', () async {
    tokens.tokens = const AuthTokens(
      accessToken: 'a',
      refreshToken: 'r',
      role: 'admin',
    );
    await repository.logout();
    expect(tokens.tokens, isNull);
  });
}
