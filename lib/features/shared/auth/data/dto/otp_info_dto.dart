import '../../../../../core/core.dart';

/// A sent code: `data.otp` of `/auth/register` and of a phone
/// `/auth/login`, or `data` of `/auth/otp/resend`.
class OtpInfoDto {
  const OtpInfoDto({
    this.sentTo,
    this.expiresAt,
    this.resendAvailableAt,
    this.length,
  });

  factory OtpInfoDto.fromJson(Json json) => OtpInfoDto(
    sentTo: json.str('sentTo'),
    expiresAt: json.date('expiresAt'),
    resendAvailableAt: json.date('resendAvailableAt'),
    length: json.integer('length'),
  );

  /// Reads `data.otp` when present, otherwise `data` itself.
  factory OtpInfoDto.fromResponse(Json json) =>
      OtpInfoDto.fromJson(json.obj('otp') ?? json);

  final String? sentTo;
  final DateTime? expiresAt;
  final DateTime? resendAvailableAt;
  final int? length;
}
