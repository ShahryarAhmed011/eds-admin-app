import '../../../../../core/core.dart';
import '../entities/auth_draft.dart';
import '../entities/otp_challenge.dart';
import '../entities/auth_result.dart';
import '../entities/signed_in_user.dart';

abstract interface class AuthRepository {
  /// Form prefill (Figma sample data offline, empty against the API).
  Future<AuthDraft> getDraft();

  /// Logs in and stores the session; the returned role comes from the
  /// login response. Throws [AccountNotVerifiedException] when the account
  /// must verify its email first, [ApiException] otherwise.
  /// Saves the email for next time when [rememberMe] is on and forgets it
  /// otherwise.
  Future<SignedInUser> signIn({
    required String email,
    required String password,
    bool rememberMe = false,
  });

  /// Phone login with the number (national digits). With [password] the
  /// account signs in straight away; without, a code is sent (continue
  /// with [verifyOtp]). Saves the number for next time when [rememberMe]
  /// is on and forgets it otherwise.
  Future<AuthResult> loginWithPhone(
    String phoneNumber, {
    String? password,
    bool rememberMe = false,
  });

  /// Creates the account. Current servers sign in straight away (the
  /// phone is verified as an onboarding step); older ones send an email
  /// code to verify first.
  Future<AuthResult> signUp(AuthDraft draft, AppRole role);

  /// The code awaiting verification (after sign up, a phone login or an
  /// unverified email login).
  Future<OtpChallenge> getPendingVerification();

  Future<OtpChallenge> resendOtp();

  /// Verifies [code] for the pending challenge (email or phone) and stores
  /// the session.
  Future<SignedInUser> verifyOtp(String code);

  /// Ends every session server-side (best effort) and clears local tokens.
  Future<void> logout();

  /// Permanently deletes the signed-in account ([password] re-confirms),
  /// then clears the local session. Throws on a wrong password; nothing is
  /// deleted and the session is kept.
  Future<void> deleteAccount(String password);
}
