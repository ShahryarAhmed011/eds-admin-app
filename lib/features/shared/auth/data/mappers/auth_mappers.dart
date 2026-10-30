import '../../../../../core/core.dart';
import '../../domain/entities/auth_draft.dart';
import '../../../common/phone_number.dart';
import '../../domain/entities/otp_challenge.dart';
import '../dto/auth_draft_dto.dart';
import '../dto/auth_session_dto.dart';
import '../dto/otp_info_dto.dart';

extension AuthSessionDtoMapper on AuthSessionDto {
  AuthTokens toTokens() => AuthTokens(
    accessToken: accessToken,
    refreshToken: refreshToken,
    role: role,
  );

  AppRole get appRole => AppRole.fromApi(role);
}

extension OtpInfoDtoMapper on OtpInfoDto {
  /// [phoneNumber] (national digits) marks a phone login code;
  /// [verifiesAccountPhone] a code for the signed-in account's phone,
  /// [accountPhone] (national digits) when the app knows that number.
  OtpChallenge toEntity({
    String email = '',
    AppRole? role,
    String? phoneNumber,
    bool verifiesAccountPhone = false,
    bool verifiesAccountEmail = false,
    String? accountPhone,
  }) {
    // The account's own number reads better than the API's masked one.
    if (verifiesAccountPhone &&
        accountPhone != null &&
        accountPhone.isNotEmpty) {
      return _challenge(
        email: email,
        role: role,
        sentTo: PhoneNumber.format(PhoneNumber.countryCode, accountPhone),
        verifiesAccountPhone: true,
      );
    }
    final fallback = switch (phoneNumber) {
      final phone? => PhoneNumber.format(PhoneNumber.countryCode, phone),
      null when verifiesAccountPhone => 'your phone number',
      null => email,
    };
    return OtpChallenge(
      email: email,
      role: role,
      phoneNumber: phoneNumber,
      sentTo: (sentTo == null || sentTo!.isEmpty) ? fallback : sentTo!,
      length: (length == null || length! <= 0)
          ? OtpChallenge.defaultLength
          : length!,
      expiresAt: expiresAt,
      resendAvailableAt: resendAvailableAt,
      verifiesAccountPhone: verifiesAccountPhone,
      verifiesAccountEmail: verifiesAccountEmail,
    );
  }

  OtpChallenge _challenge({
    required String email,
    required AppRole? role,
    required String sentTo,
    required bool verifiesAccountPhone,
  }) => OtpChallenge(
    email: email,
    role: role,
    sentTo: sentTo,
    length: (length == null || length! <= 0)
        ? OtpChallenge.defaultLength
        : length!,
    expiresAt: expiresAt,
    resendAvailableAt: resendAvailableAt,
    verifiesAccountPhone: verifiesAccountPhone,
  );
}

extension AuthDraftDtoMapper on AuthDraftDto {
  AuthDraft toEntity() => AuthDraft(
    firstName: firstName,
    lastName: lastName,
    email: email,
    password: password,
    phoneNumber: phoneNumber,
    acceptedTerms: acceptedTerms,
  );
}
