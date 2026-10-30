import 'otp_challenge.dart';
import 'signed_in_user.dart';

/// Outcome of a login or sign up: signed in straight away, or a code was
/// sent to verify first.
sealed class AuthResult {
  const AuthResult();
}

final class AuthSignedIn extends AuthResult {
  const AuthSignedIn(this.user);

  final SignedInUser user;
}

final class AuthCodeSent extends AuthResult {
  const AuthCodeSent(this.challenge);

  final OtpChallenge challenge;
}
