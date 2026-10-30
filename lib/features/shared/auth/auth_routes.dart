import 'package:go_router/go_router.dart';

import '../../../core/core.dart';
import 'presentation/screens/otp_screen.dart';
import 'presentation/screens/sign_in_screen.dart';
import 'presentation/screens/sign_up_screen.dart';
import 'presentation/widgets/app_role_ui.dart';

/// Signed-out flow: sign in with phone or email and a password → role
/// home (or → OTP when a code is needed); the role comes from the API. New
/// accounts: sign in → sign up (this app's role) → signed in, then the
/// onboarding gate (verify phone, …).
final List<RouteBase> sharedAuthRoutes = [
  GoRoute(path: AppRoutes.signIn, builder: (_, _) => const SignInScreen()),
  // Admin accounts are provisioned, so the admin app has no sign up.
  if (AppConfig.appRole.canSelfRegister)
    GoRoute(path: AppRoutes.signUp, builder: (_, _) => const SignUpScreen()),
  GoRoute(
    path: AppRoutes.otpVerification,
    builder: (_, _) => const OtpScreen(),
  ),
  // Onboarding: the signed-in account's phone or email, same screen; back
  // signs out.
  GoRoute(path: AppRoutes.verifyPhone, builder: (_, _) => const OtpScreen()),
  GoRoute(path: AppRoutes.verifyEmail, builder: (_, _) => const OtpScreen()),
];
