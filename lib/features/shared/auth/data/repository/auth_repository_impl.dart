import '../../../../../core/core.dart';
import '../../domain/entities/auth_draft.dart';
import '../../domain/entities/auth_exceptions.dart';
import '../../domain/entities/otp_challenge.dart';
import '../../domain/entities/auth_result.dart';
import '../../domain/entities/signed_in_user.dart';
import '../../domain/repository/auth_repository.dart';
import '../../../common/phone_number.dart';
import '../data_sources/auth_data_source.dart';
import '../data_sources/remembered_login_storage.dart';
import '../dto/auth_session_dto.dart';
import '../dto/otp_info_dto.dart';
import '../dto/register_request_dto.dart';
import '../mappers/auth_mappers.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(
    this._dataSource,
    this._tokens, [
    this._remembered,
    this._onboarding,
    this._cache,
    this._appRole,
  ]);

  final AuthDataSource _dataSource;
  final TokenStorage _tokens;

  /// "Remember me" storage; null turns the feature off.
  final RememberedLoginStorage? _remembered;

  /// Records the onboarding status from login / sign up (the session);
  /// null turns the onboarding gate off.
  final OnboardingTracker? _onboarding;

  /// Keeps the login `user` on the device (cleared on sign out).
  final SessionCache? _cache;

  /// The role this app is built for: a login as any other role is refused
  /// before a session is written. Null (tests) accepts every role.
  final AppRole? _appRole;

  /// Error codes the API may use when an account exists but its email
  /// hasn't been verified yet. The docs don't list one, so 403 also counts.
  static const _unverifiedCodes = {
    'email_not_verified',
    'account_not_verified',
    'unverified_account',
    'verification_required',
    'otp_required',
  };

  late AppRole _selectedRole = _appRole ?? AppRole.customer;
  OtpChallenge? _pending;

  /// The signed-in account's phone (national digits) and email, shown on
  /// the verify screen: what it logged in or signed up with.
  String? _accountPhone;
  String? _accountEmail;

  @override
  Future<AuthDraft> getDraft() async {
    final draft =
        (await _dataSource.fetchPrefill())?.toEntity() ?? const AuthDraft();
    final remembered = _remembered;
    if (remembered == null) return draft;
    final (phone, email) = await (
      remembered.readPhone(),
      remembered.readEmail(),
    ).wait;
    // Remembered values fill only what the prefill left empty.
    return draft.copyWith(
      phoneNumber:
          draft.phoneNumber.isEmpty && phone != null && phone.isNotEmpty
          ? phone
          : null,
      email: draft.email.isEmpty && email != null && email.isNotEmpty
          ? email
          : null,
    );
  }

  @override
  Future<SignedInUser> signIn({
    required String email,
    required String password,
    bool rememberMe = false,
  }) async {
    try {
      final session = await _dataSource.login(email: email, password: password);
      await _rememberEmail(email, rememberMe);
      _accountEmail = email;
      // An email login verifies the email (the API emails the code).
      return _startSession(session, verifyVia: VerifyVia.email);
    } on ApiException catch (e) {
      if (e.status != 403 && !_unverifiedCodes.contains(e.code)) rethrow;
      await _rememberEmail(email, rememberMe);
      final otp = await _dataSource.resendOtp(email: email);
      throw AccountNotVerifiedException(_pending = otp.toEntity(email: email));
    }
  }

  @override
  Future<AuthResult> loginWithPhone(
    String phoneNumber, {
    String? password,
    bool rememberMe = false,
  }) async {
    final digits = PhoneNumber.nationalDigits(phoneNumber);
    final response = await _dataSource.phoneLogin(
      phoneCountryCode: PhoneNumber.countryCode,
      phoneNumber: digits,
      password: password,
    );
    await (rememberMe
        ? _remembered?.writePhone(digits)
        : _remembered?.clearPhone());
    _accountPhone = digits;
    if (response.session case final session?) {
      return AuthSignedIn(await _startSession(session));
    }
    return AuthCodeSent(_pending = response.otp!.toEntity(phoneNumber: digits));
  }

  /// Sends a fresh phone login code (never with a password, which would
  /// sign in instead).
  Future<OtpChallenge> _requestPhoneCode(String digits) async {
    final response = await _dataSource.phoneLogin(
      phoneCountryCode: PhoneNumber.countryCode,
      phoneNumber: digits,
    );
    return _pending = response.otp!.toEntity(phoneNumber: digits);
  }

  @override
  Future<AuthResult> signUp(AuthDraft draft, AppRole role) async {
    final email = draft.email.trim();
    final registration = await _dataSource.register(
      RegisterRequestDto(
        firstName: draft.firstName.trim(),
        lastName: draft.lastName.trim(),
        email: email,
        password: draft.password,
        role: role.apiValue,
        phoneCountryCode: PhoneNumber.countryCode,
        phoneNumber: PhoneNumber.nationalDigits(draft.phoneNumber),
      ),
    );
    // Sign up signs in. Its code goes to the email or the phone: the
    // masked `sentTo` says which, and that's the contact verified first.
    _accountPhone = PhoneNumber.nationalDigits(draft.phoneNumber);
    _accountEmail = email;
    if (registration.session case final session?) {
      final emailed = registration.otp?.sentTo?.contains('@') ?? false;
      return AuthSignedIn(
        await _startSession(
          session,
          code: registration.otp,
          verifyVia: emailed ? VerifyVia.email : VerifyVia.phone,
        ),
      );
    }
    // Older servers: no session, verify the email first.
    final verifiedEmail = registration.email.isEmpty
        ? email
        : registration.email;
    final otp = registration.otp;
    return AuthCodeSent(
      _pending = otp != null
          ? otp.toEntity(email: verifiedEmail, role: role)
          : OtpChallenge(
              email: verifiedEmail,
              role: role,
              sentTo: verifiedEmail,
            ),
    );
  }

  @override
  Future<OtpChallenge> getPendingVerification() async {
    if (_pending case final pending?) return pending;
    // Signed in with a contact still to verify (e.g. after a restart).
    if (_onboarding?.onboardingStep case final step?
        when step == OnboardingStep.verifyPhone ||
            step == OnboardingStep.verifyEmail) {
      if (_accountPhone == null || _accountEmail == null) {
        final contact = await _loadProfile(cached: true);
        _accountPhone ??= contact.phone;
        _accountEmail ??= contact.email;
      }
      return _pending = _accountChallenge(step, _onboarding?.role);
    }
    final email = (await getDraft()).email;
    return OtpChallenge(email: email, role: _selectedRole, sentTo: email);
  }

  @override
  Future<OtpChallenge> resendOtp() async {
    final pending = await getPendingVerification();
    if (pending.verifiesAccountPhone) {
      final otp = await _dataSource.sendPhoneOtp();
      return _pending = otp.toEntity(
        role: pending.role,
        verifiesAccountPhone: true,
        accountPhone: _accountPhone,
      );
    }
    // A phone login code is resent by requesting the login again.
    if (pending.phoneNumber case final phone?) return _requestPhoneCode(phone);
    final otp = await _dataSource.resendOtp(
      email: pending.email,
      role: pending.role?.apiValue,
    );
    return _pending = otp.toEntity(
      email: pending.email,
      role: pending.role,
      verifiesAccountEmail: pending.verifiesAccountEmail,
    );
  }

  @override
  Future<SignedInUser> verifyOtp(String code) async {
    final pending = await getPendingVerification();
    if (pending.verifiesAccountPhone) return _verifyAccountPhone(code);
    if (pending.verifiesAccountEmail) return _verifyAccountEmail(pending, code);
    final session = switch (pending.phoneNumber) {
      final phone? => await _dataSource.verifyPhoneOtp(
        phoneCountryCode: PhoneNumber.countryCode,
        phoneNumber: phone,
        code: code,
      ),
      null => await _dataSource.verifyEmailOtp(
        email: pending.email,
        code: code,
      ),
    };
    _pending = null;
    return _startSession(session);
  }

  @override
  Future<void> logout() async {
    try {
      await _dataSource.logout();
    } catch (_) {
      // Server-side revocation is best effort; local sign out must happen.
    } finally {
      await _tokens.clear();
    }
  }

  @override
  Future<void> deleteAccount(String password) async {
    // A wrong password throws here and nothing is deleted; only clear the
    // local session once the server confirms the account is gone.
    await _dataSource.deleteAccount(password);
    await _tokens.clear();
  }

  Future<void> _rememberEmail(String email, bool rememberMe) async {
    await (rememberMe
        ? _remembered?.writeEmail(email)
        : _remembered?.clearEmail());
  }

  /// Saves the session. The onboarding status goes first so the router
  /// gate is ready the moment the tokens sign the user in. When the contact
  /// it logged in with ([verifyVia]) isn't verified, the code screen gets
  /// a challenge for it; the API has already sent the code ([code], else
  /// the response's own `otp`, describes it).
  Future<SignedInUser> _startSession(
    AuthSessionDto session, {
    OtpInfoDto? code,
    VerifyVia verifyVia = VerifyVia.phone,
  }) async {
    final phoneCode = code ?? session.otp;
    final role = session.appRole;
    if (_appRole case final expected? when role != expected) {
      throw ApiException(
        status: 403,
        code: ApiErrorCode.wrongApp,
        message:
            'This is a ${role.label.toLowerCase()} account. '
            'Use the ${role.appName} app to sign in.',
      );
    }
    final status = session.status?.verifying(verifyVia);
    final step = switch (status?.nextStep(role)) {
      final step?
          when step == OnboardingStep.verifyPhone ||
              step == OnboardingStep.verifyEmail =>
        step,
      _ => null,
    };
    await _onboarding?.setOnboarding(status);
    if (session.user case final user?) {
      await _cache?.write(SessionCacheKeys.user, user);
    }
    if (step != null) _pending = _accountChallenge(step, role, phoneCode);
    await _tokens.write(session.toTokens());
    _selectedRole = role;
    // The profile is only needed when a contact still has to be verified
    // (the code screen shows it) or the app keeps account data on the
    // device; otherwise — e.g. straight on to the catalogue gate — skip
    // the call. A verify step found later loads it itself.
    if (step != null || AppConfig.persistAccountData) {
      final contact = await _loadProfile();
      _accountPhone ??= contact.phone;
      _accountEmail ??= contact.email;
      if (step != null && (_pending?.verifiesAccount ?? false)) {
        _pending = _accountChallenge(step, role, phoneCode);
      }
    }
    // A retailer's store goes on the device too (while the app keeps
    // account data), so the store screens read it locally instead of each
    // calling the API.
    if (role == AppRole.retailer && AppConfig.persistAccountData) {
      await _loadStore();
    }
    return SignedInUser(role: role);
  }

  /// The code screen's challenge for verifying the account's phone or
  /// email ([step]).
  OtpChallenge _accountChallenge(
    OnboardingStep step,
    AppRole? role, [
    OtpInfoDto? code,
  ]) => step == OnboardingStep.verifyEmail
      ? (code ?? const OtpInfoDto()).toEntity(
          email: _accountEmail ?? '',
          role: role,
          verifiesAccountEmail: true,
        )
      : (code ?? const OtpInfoDto()).toEntity(
          role: role,
          verifiesAccountPhone: true,
          accountPhone: _accountPhone,
        );

  /// `GET /profile`, kept on the device for the profile screens; with
  /// [cached], the device copy when there is one. Returns the account's
  /// phone and email. Best effort: the verify screen falls back to "your
  /// phone number" / no email.
  Future<({String? phone, String? email})> _loadProfile({
    bool cached = false,
  }) async {
    try {
      var profile = cached
          ? await _cache?.read(SessionCacheKeys.profile)
          : null;
      if (profile == null) {
        profile = await _dataSource.fetchProfile();
        if (AppConfig.persistAccountData) {
          await _cache?.write(SessionCacheKeys.profile, profile);
        }
      }
      return (phone: profile.str('phoneNumber'), email: profile.str('email'));
    } catch (_) {
      return (phone: null, email: null);
    }
  }

  /// `GET /store`, kept on the device for the retailer screens (none when
  /// the store isn't created yet). Best effort: a failure only means the
  /// first store screen fetches it itself.
  Future<void> _loadStore() async {
    try {
      final store = await _dataSource.fetchStore();
      if (store != null) await _cache?.write(SessionCacheKeys.store, store);
    } catch (_) {
      // The screens fetch it themselves.
    }
  }

  /// `POST /auth/otp/verify` with the account's email, then the gate moves
  /// on: the response's `status` when sent, otherwise the email marked
  /// verified.
  Future<SignedInUser> _verifyAccountEmail(
    OtpChallenge pending,
    String code,
  ) async {
    final session = await _dataSource.verifyEmailOtp(
      email: pending.email,
      code: code,
    );
    _pending = null;
    final role = _onboarding?.role ?? session.appRole;
    if (session.accessToken.isNotEmpty) {
      await _tokens.write(session.toTokens());
    }
    final onboarding = _onboarding;
    if (onboarding != null) {
      await switch (session.status) {
        final status? => onboarding.setOnboarding(
          status.verifying(VerifyVia.email),
        ),
        null => onboarding.completeOnboarding(OnboardingStep.verifyEmail),
      };
    }
    return SignedInUser(role: role);
  }

  /// `POST /auth/phone/verify`, then the gate moves to the next step: the
  /// response's `status` when sent, otherwise the phone marked verified.
  Future<SignedInUser> _verifyAccountPhone(String code) async {
    final data = await _dataSource.verifyPhone(code);
    _pending = null;
    final role = _onboarding?.role ?? _selectedRole;
    if (AuthSessionDto.hasSession(data)) {
      await _tokens.write(AuthSessionDto.fromJson(data).toTokens());
    }
    final onboarding = _onboarding;
    if (onboarding != null) {
      await switch (data.obj('status')) {
        final status? => onboarding.setOnboarding(
          OnboardingStatus.fromJson(status),
        ),
        null => onboarding.completeOnboarding(OnboardingStep.verifyPhone),
      };
    }
    return SignedInUser(role: role);
  }
}
