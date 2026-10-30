import 'package:eds_admin_app/core/core.dart';
import 'package:eds_admin_app/features/shared/auth/data/data_sources/auth_dummy_data_source.dart';
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

/// The API as of the new login / sign up: sessions carry a `status` block
/// and the account's phone is verified through `/auth/phone/*`.
class _OnboardingApi extends AuthDummyDataSource {
  final calls = <String>[];

  static const unverified = {
    'isEmailVerified': true,
    'isPhoneVerified': false,
    'isProfileCreated': false,
    'isStoreCreated': false,
    'isKYCCompleted': false,
    'canGoLive': false,
  };

  Json _session(String role) => {
    'accessToken': 'a',
    'refreshToken': 'r',
    'role': role,
    'status': unverified,
  };

  @override
  Future<PhoneLoginDto> phoneLogin({
    required String phoneCountryCode,
    required String phoneNumber,
    String? password,
  }) async {
    calls.add('login');
    return PhoneLoginDto.fromResponse(_session('retailer'));
  }

  @override
  Future<RegistrationDto> register(RegisterRequestDto request) async {
    calls.add('signup ${request.toJson()['roleId']}');
    return RegistrationDto.fromJson({
      'email': request.email,
      'role': request.role,
      'otp': {'sentTo': '+92······4567', 'length': 6},
      ..._session(request.role),
    });
  }

  @override
  Future<AuthSessionDto> login({
    required String email,
    required String password,
  }) async {
    calls.add('email login');
    return AuthSessionDto.fromJson({
      ..._session('customer'),
      'status': {...unverified, 'isEmailVerified': emailVerified},
    });
  }

  /// Whether the session is signed in when the profile is asked.
  bool Function() signedIn = () => false;

  /// `GET /profile` calls, and whether each was signed in.
  final profileCalls = <bool>[];

  @override
  Future<Json> fetchProfile() async {
    profileCalls.add(signedIn());
    return const {
      'phoneNumber': '3005551234',
      'email': 'user@example.com',
      'firstName': 'Shahryar',
    };
  }

  /// Email login: whether the account's email is verified yet.
  bool emailVerified = true;

  @override
  Future<AuthSessionDto> verifyEmailOtp({
    required String email,
    required String code,
  }) async {
    calls.add('otp/verify $email $code');
    return AuthSessionDto.fromJson({
      ..._session('customer'),
      'status': {...unverified, 'isEmailVerified': true},
    });
  }

  @override
  Future<OtpInfoDto> resendOtp({required String email, String? role}) async {
    calls.add('otp/resend $email');
    return OtpInfoDto(sentTo: email, length: 6);
  }

  @override
  Future<OtpInfoDto> sendPhoneOtp() async {
    calls.add('phone/send-otp');
    return const OtpInfoDto(sentTo: '+92······4567', length: 6);
  }

  @override
  Future<Json> verifyPhone(String code) async {
    calls.add('phone/verify $code');
    return const {};
  }
}

void main() {
  late _OnboardingApi api;
  late AuthSession session;
  late AuthRepositoryImpl repository;

  setUp(() {
    api = _OnboardingApi();
    session = AuthSession(_MemoryTokens(), MemoryOnboardingStorage());
    repository = AuthRepositoryImpl(api, session, null, session);
    api.signedIn = () => session.isSignedIn;
  });

  test(
    'login with an unverified phone signs in and gates on the phone',
    () async {
      final result = await repository.loginWithPhone(
        '3009373596',
        password: 'Test@123',
      );
      expect(result, isA<AuthSignedIn>());
      expect(session.role, AppRole.retailer);
      expect(session.onboardingStep, OnboardingStep.verifyPhone);

      final challenge = await repository.getPendingVerification();
      expect(challenge.verifiesAccountPhone, isTrue);
      expect(challenge.isPhone, isTrue);
      // The number the user logged in with.
      expect(challenge.sentTo, '+92 300-9373596');
    },
  );

  test('an email login with an unverified email verifies the email', () async {
    api.emailVerified = false;
    await repository.signIn(email: 'user@example.com', password: 'Abcd1234');
    expect(session.onboardingStep, OnboardingStep.verifyEmail);

    final challenge = await repository.getPendingVerification();
    expect(challenge.verifiesAccountEmail, isTrue);
    expect(challenge.isPhone, isFalse);
    expect(challenge.sentTo, 'user@example.com');

    await repository.resendOtp();
    await repository.verifyOtp('123456');
    expect(api.calls, [
      'email login',
      'otp/resend user@example.com',
      'otp/verify user@example.com 123456',
    ]);
    // Email replaces the phone for an email login: on to the profile.
    expect(session.onboardingStep, OnboardingStep.profile);
  });

  test('an email login with a verified email skips verification', () async {
    await repository.signIn(email: 'user@example.com', password: 'Abcd1234');
    expect(session.onboardingStep, OnboardingStep.profile);
  });

  test('the email step survives a restart', () async {
    api.emailVerified = false;
    await repository.signIn(email: 'user@example.com', password: 'Abcd1234');
    final fresh = AuthRepositoryImpl(api, session, null, session);
    final challenge = await fresh.getPendingVerification();
    expect(challenge.verifiesAccountEmail, isTrue);
    expect(challenge.sentTo, 'user@example.com');
  });

  test('the phone code is resent and verified via /auth/phone', () async {
    await repository.loginWithPhone('3009373596', password: 'Test@123');
    final resent = await repository.resendOtp();
    expect(resent.sentTo, '+92 300-9373596');

    final user = await repository.verifyOtp('123456');
    expect(user.role, AppRole.retailer);
    expect(api.calls, ['login', 'phone/send-otp', 'phone/verify 123456']);
    // On to the next step.
    expect(session.onboardingStep, OnboardingStep.profile);
  });

  test('sign up signs in and shows the phone code it sent', () async {
    final result = await repository.signUp(
      const AuthDraft(
        firstName: 'Ali',
        lastName: 'Khan',
        email: 'user@example.com',
        password: 'Abcd1234',
        phoneNumber: '3001234567',
        acceptedTerms: true,
      ),
      AppRole.rider,
    );
    expect(result, isA<AuthSignedIn>());
    expect(api.calls, ['signup 3']);
    expect(session.role, AppRole.rider);
    expect(session.onboardingStep, OnboardingStep.verifyPhone);
    final challenge = await repository.getPendingVerification();
    expect(challenge.sentTo, '+92 300-1234567');
  });

  test('after a restart the phone step still has a code screen', () async {
    await session.setOnboarding(
      AuthSessionDto.fromJson({
        'accessToken': 'a',
        'refreshToken': 'r',
        'role': 'customer',
        'status': _OnboardingApi.unverified,
      }).status,
    );
    await session.write(
      const AuthTokens(accessToken: 'a', refreshToken: 'r', role: 'customer'),
    );
    final fresh = AuthRepositoryImpl(api, session, null, session);
    final challenge = await fresh.getPendingVerification();
    expect(challenge.verifiesAccountPhone, isTrue);
    expect(challenge.sentTo, '+92 300-5551234');
  });
}
