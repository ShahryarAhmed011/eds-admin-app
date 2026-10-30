import 'package:eds_admin_app/core/core.dart';
import 'package:eds_admin_app/features/shared/profile/data/dto/user_profile_dto.dart';
import 'package:eds_admin_app/features/shared/profile/data/mappers/user_profile_mapper.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final dto = UserProfileDto.fromJson(const {
    'id': 7,
    'email': 'ali@example.com',
    'active': true,
    'phoneCountryCode': '+92',
    'phoneNumber': '3001234567',
    'firstName': 'Ali',
    'lastName': 'Khan',
    'username': 'alikhan',
    'role': 'retailer',
    'dateOfBirth': '1995-04-17',
    'gender': 'male',
  });

  test('joins names and formats the phone', () {
    final profile = dto.toEntity(
      language: 'English',
      availableLanguages: const ['English'],
    );

    expect(profile.fullName, 'Ali Khan');
    expect(profile.phone, '+92 300-1234567');
    expect(profile.role, AppRole.retailer);
    expect(profile.phoneVerified, isNull);
  });

  test('edits split the name and keep untouched fields for PUT', () {
    final edited = dto
        .toEntity(language: 'English', availableLanguages: const ['English'])
        .copyWith(fullName: 'Ali Raza Khan', phone: '0333 7654321');
    final body = dto.withEdits(edited).toUpdateJson();

    expect(body['firstName'], 'Ali');
    expect(body['lastName'], 'Raza Khan');
    expect(body['phoneCountryCode'], '+92');
    expect(body['phoneNumber'], '3337654321');
    expect(body['username'], 'alikhan');
    expect(body['dateOfBirth'], '1995-04-17');
    expect(body.containsKey('email'), isFalse);
  });
}
