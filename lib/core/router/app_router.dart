import 'package:go_router/go_router.dart';

import '../../features/feature_registry.dart';
import '../../features/splash/splash.dart';
import '../di/injection.dart';
import '../session/app_role.dart';
import '../session/auth_session.dart';
import '../session/onboarding.dart';
import 'app_routes.dart';
import 'role_home.dart';

/// Routes reachable without a session.
const _authRoutes = {
  AppRoutes.signIn,
  AppRoutes.signUp,
  AppRoutes.otpVerification,
};

final GoRouter appRouter = GoRouter(
  initialLocation: AppRoutes.splash,
  refreshListenable: sl<AuthSession>(),
  redirect: (context, state) =>
      authRedirect(sl<AuthSession>(), state.matchedLocation),
  routes: [
    GoRoute(
      path: AppRoutes.splash,
      builder: (context, state) => const SplashScreen(),
    ),
    ...FeatureRegistry.routes,
  ],
);

/// Route guard:
/// - the splash decides where to go once the stored session is restored;
/// - signed out → only auth routes, everything else goes to sign in;
/// - signed in with onboarding left → only the current step's screens
///   (verify phone, profile, store, KYC), everything else goes there;
/// - signed in → auth routes and other roles' areas go to the home of the
///   role the login response returned.
/// Shared routes (profile, location) are open to every signed-in role.
String? authRedirect(AuthSession session, String location) {
  if (location == AppRoutes.splash) return null;
  if (!session.isRestored) return AppRoutes.splash;

  final role = session.role;
  final isAuthRoute = _authRoutes.contains(location);
  if (role == null) return isAuthRoute ? null : AppRoutes.signIn;

  if (session.onboardingStep case final step?) {
    return step.allows(role, location) ? null : step.route(role);
  }
  if (const {
    AppRoutes.verifyPhone,
    AppRoutes.verifyEmail,
    AppRoutes.completeProfile,
    AppRoutes.createShop,
    AppRoutes.verifyIdentity,
  }.contains(location)) {
    return role.homeRoute;
  }
  if (isAuthRoute) return role.homeRoute;

  final ownedByOtherRole = AppRole.values.any(
    (r) => r != role && location.startsWith(r.routePrefix),
  );
  return ownedByOtherRole ? role.homeRoute : null;
}

/// Where each onboarding step lives.
extension OnboardingStepRoutes on OnboardingStep {
  /// The screen the user is sent to for this step.
  String route(AppRole role) => switch (this) {
    OnboardingStep.verifyEmail => AppRoutes.verifyEmail,
    OnboardingStep.verifyPhone => AppRoutes.verifyPhone,
    OnboardingStep.profile => AppRoutes.completeProfile,
    OnboardingStep.store => AppRoutes.createShop,
    OnboardingStep.kyc => AppRoutes.verifyIdentity,
    OnboardingStep.catalog => AppRoutes.retailerGlobalCatalogue,
  };

  /// Screens the user may be on during this step.
  bool allows(AppRole role, String location) => switch (this) {
    OnboardingStep.verifyEmail => location == AppRoutes.verifyEmail,
    OnboardingStep.verifyPhone => location == AppRoutes.verifyPhone,
    OnboardingStep.profile => location == AppRoutes.completeProfile,
    OnboardingStep.store => location == AppRoutes.createShop,
    OnboardingStep.kyc => location == AppRoutes.verifyIdentity,
    // The catalogue, plus the screens that add products to it.
    OnboardingStep.catalog => const {
      AppRoutes.retailerGlobalCatalogue,
      AppRoutes.retailerCatalogueReview,
      AppRoutes.retailerBulkAddSelection,
      AppRoutes.retailerBulkAddResults,
      AppRoutes.retailerScanBarcode,
      AppRoutes.retailerProductRequests,
    }.contains(location),
  };
}
