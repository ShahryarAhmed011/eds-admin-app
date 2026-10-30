import 'package:eds_admin_app/core/core.dart';
import 'package:eds_admin_app/features/shared/auth/data/dto/auth_session_dto.dart';
import 'package:eds_admin_app/features/shared/auth/data/dto/otp_info_dto.dart';
import 'package:eds_admin_app/features/shared/auth/data/dto/registration_dto.dart';
import 'package:eds_admin_app/features/shared/auth/data/mappers/auth_mappers.dart';
import 'package:eds_admin_app/features/shared/auth/domain/entities/otp_challenge.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AuthSessionDto', () {
    // `data` of POST /auth/login and /auth/otp/verify.
    const json = {
      'accessToken': 'eyJhbGciOi.access',
      'tokenType': 'bearer',
      'expiresIn': 900,
      'refreshToken': 'eyJhbGciOi.refresh',
      'refreshExpiresIn': 2592000,
      'role': 'retailer',
      'user': {'id': 42, 'email': 'user@example.com'},
    };

    test('maps to AuthTokens and AppRole', () {
      final dto = AuthSessionDto.fromJson(json);
      final tokens = dto.toTokens();

      expect(tokens.accessToken, 'eyJhbGciOi.access');
      expect(tokens.refreshToken, 'eyJhbGciOi.refresh');
      expect(tokens.role, 'retailer');
      expect(dto.appRole, AppRole.retailer);
      expect(dto.expiresIn, 900);
    });

    test('matches core AuthTokens.fromJson on the same payload', () {
      final fromCore = AuthTokens.fromJson(json);
      final fromDto = AuthSessionDto.fromJson(json).toTokens();

      expect(fromDto.accessToken, fromCore.accessToken);
      expect(fromDto.refreshToken, fromCore.refreshToken);
      expect(fromDto.role, fromCore.role);
    });
  });

  group('OtpInfoDto', () {
    test('maps resend payload to an OtpChallenge', () {
      final dto = OtpInfoDto.fromJson(const {
        'sentTo': 'u***@example.com',
        'expiresAt': '2026-08-22T15:10:00Z',
        'resendAvailableAt': '2026-08-22T15:01:00Z',
        'length': 4,
      });
      final challenge = dto.toEntity(
        email: 'user@example.com',
        role: AppRole.rider,
      );

      expect(challenge.email, 'user@example.com');
      expect(challenge.role, AppRole.rider);
      expect(challenge.sentTo, 'u***@example.com');
      expect(challenge.length, 4);
      expect(challenge.resendAvailableAt, DateTime.utc(2026, 8, 22, 15, 1));
      expect(challenge.expiresAt, DateTime.utc(2026, 8, 22, 15, 10));
    });

    test('falls back to the email and default length', () {
      final challenge = OtpInfoDto.fromJson(
        const {},
      ).toEntity(email: 'user@example.com', role: AppRole.customer);

      expect(challenge.sentTo, 'user@example.com');
      expect(challenge.length, OtpChallenge.defaultLength);
      expect(challenge.resendAvailableAt, isNull);
    });
  });

  test('RegistrationDto reads ids as strings and the nested otp', () {
    final dto = RegistrationDto.fromJson(const {
      'userId': 101,
      'email': 'user@example.com',
      'role': 'customer',
      'onboardingStatus': 'pending_verification',
      'username': 'user',
      'otp': {'sentTo': 'user@example.com', 'length': 6},
    });

    expect(dto.userId, '101');
    expect(dto.otp?.length, 6);
    expect(dto.otp?.sentTo, 'user@example.com');
  });
}
