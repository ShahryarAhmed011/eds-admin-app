import 'otp_challenge.dart';

/// Login succeeded on credentials but the account still needs its email
/// verified. A fresh code has been sent; continue on the OTP screen.
class AccountNotVerifiedException implements Exception {
  const AccountNotVerifiedException(this.challenge);

  final OtpChallenge challenge;
}
