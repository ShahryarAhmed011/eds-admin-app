import 'package:eds_admin_app/core/network/token_storage.dart';
import 'package:eds_admin_app/core/router/app_router.dart';
import 'package:eds_admin_app/core/router/app_routes.dart';
import 'package:eds_admin_app/core/session/app_role.dart';
import 'package:eds_admin_app/core/session/auth_session.dart';
import 'package:eds_admin_app/core/session/onboarding.dart';
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

AuthTokens _tokens(AppRole role) =>
    AuthTokens(accessToken: 'a', refreshToken: 'r', role: role.apiValue);

void main() {
  late AuthSession session;

  setUp(() => session = AuthSession(_MemoryTokens()));

  test('before restore everything waits on the splash', () {
    expect(authRedirect(session, AppRoutes.splash), isNull);
    expect(authRedirect(session, AppRoutes.customerHome), AppRoutes.splash);
  });

  group('signed out', () {
    setUp(() => session.restore());

    test('auth routes are open', () {
      for (final route in [
        AppRoutes.signIn,
        AppRoutes.signUp,
        AppRoutes.otpVerification,
      ]) {
        expect(authRedirect(session, route), isNull, reason: route);
      }
    });

    test('protected routes go to sign in', () {
      expect(authRedirect(session, AppRoutes.adminQueues), AppRoutes.signIn);
      expect(authRedirect(session, AppRoutes.profile), AppRoutes.signIn);
    });
  });

  group('signed in', () {
    test('auth routes go to the role home', () async {
      await session.write(_tokens(AppRole.retailer));
      expect(authRedirect(session, AppRoutes.signIn), AppRoutes.retailerHome);
    });

    test("another role's area goes to the role home", () async {
      await session.write(_tokens(AppRole.customer));
      expect(
        authRedirect(session, AppRoutes.adminUsers),
        AppRoutes.customerHome,
      );
      expect(
        authRedirect(session, AppRoutes.riderHome),
        AppRoutes.customerHome,
      );
    });

    test('own area and shared routes are allowed', () async {
      await session.write(_tokens(AppRole.admin));
      expect(authRedirect(session, AppRoutes.adminAuditLog), isNull);
      expect(authRedirect(session, AppRoutes.profile), isNull);
      expect(authRedirect(session, AppRoutes.locationCountry), isNull);
    });

    test(
      'signing out notifies listeners and closes protected routes',
      () async {
        await session.write(_tokens(AppRole.rider));
        var notified = false;
        session.addListener(() => notified = true);

        await session.clear();

        expect(notified, isTrue);
        expect(authRedirect(session, AppRoutes.riderHome), AppRoutes.signIn);
      },
    );
  });

  group('onboarding', () {
    Future<void> signIn(AppRole role, OnboardingStatus status) async {
      await session.setOnboarding(status);
      await session.write(_tokens(role));
    }

    test('an unverified phone goes to verify phone first', () async {
      await signIn(AppRole.retailer, const OnboardingStatus());
      expect(
        authRedirect(session, AppRoutes.retailerHome),
        AppRoutes.verifyPhone,
      );
      expect(authRedirect(session, AppRoutes.verifyPhone), isNull);
      expect(authRedirect(session, AppRoutes.profile), AppRoutes.verifyPhone);
    });

    test('an email login goes to verify email', () async {
      await signIn(
        AppRole.customer,
        const OnboardingStatus(verifyVia: VerifyVia.email),
      );
      expect(
        authRedirect(session, AppRoutes.customerHome),
        AppRoutes.verifyEmail,
      );
      expect(authRedirect(session, AppRoutes.verifyEmail), isNull);
      expect(
        authRedirect(session, AppRoutes.verifyPhone),
        AppRoutes.verifyEmail,
      );
    });

    test('every step locks the app to its screens, in order', () async {
      await signIn(
        AppRole.retailer,
        const OnboardingStatus(phoneVerified: true),
      );
      expect(
        authRedirect(session, AppRoutes.retailerHome),
        AppRoutes.completeProfile,
      );
      expect(authRedirect(session, AppRoutes.completeProfile), isNull);

      await session.completeOnboarding(OnboardingStep.profile);
      expect(
        authRedirect(session, AppRoutes.retailerHome),
        AppRoutes.createShop,
      );
      expect(authRedirect(session, AppRoutes.createShop), isNull);

      await session.completeOnboarding(OnboardingStep.store);
      expect(
        authRedirect(session, AppRoutes.retailerHome),
        AppRoutes.verifyIdentity,
      );
      expect(authRedirect(session, AppRoutes.verifyIdentity), isNull);

      await session.completeOnboarding(OnboardingStep.kyc);
      expect(
        authRedirect(session, AppRoutes.retailerHome),
        AppRoutes.retailerGlobalCatalogue,
      );
      expect(authRedirect(session, AppRoutes.retailerGlobalCatalogue), isNull);

      await session.completeOnboarding(OnboardingStep.catalog);
      expect(authRedirect(session, AppRoutes.retailerHome), isNull);
      expect(
        authRedirect(session, AppRoutes.verifyPhone),
        AppRoutes.retailerHome,
      );
    });

    test('riders skip the store; customers stop after the profile', () async {
      await signIn(
        AppRole.rider,
        const OnboardingStatus(phoneVerified: true, profileCreated: true),
      );
      expect(
        authRedirect(session, AppRoutes.riderHome),
        AppRoutes.verifyIdentity,
      );

      await session.clear();
      await signIn(
        AppRole.customer,
        const OnboardingStatus(phoneVerified: true, profileCreated: true),
      );
      expect(authRedirect(session, AppRoutes.customerHome), isNull);
    });

    test('no status from the API means no gate', () async {
      await session.write(_tokens(AppRole.retailer));
      expect(authRedirect(session, AppRoutes.retailerHome), isNull);
    });

    test('signing out forgets the status', () async {
      await signIn(AppRole.customer, const OnboardingStatus());
      await session.clear();
      expect(session.onboarding, isNull);
    });
  });
}
