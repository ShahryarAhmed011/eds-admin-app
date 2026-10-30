import '../../../../../core/core.dart';
import '../../../common/phone_number.dart';
import '../../domain/entities/profile_details.dart';
import '../../domain/entities/user_profile.dart';
import '../dto/user_profile_dto.dart';

extension UserProfileDtoMapper on UserProfileDto {
  UserProfile toEntity({
    required String language,
    required List<String> availableLanguages,
  }) => UserProfile(
    fullName: [
      ?firstName,
      ?lastName,
    ].where((part) => part.trim().isNotEmpty).join(' '),
    email: email,
    role: AppRole.fromApi(role),
    phone: PhoneNumber.format(phoneCountryCode, phoneNumber),
    language: language,
    availableLanguages: availableLanguages,
    city: cityName,
    phoneVerified: phoneVerified,
    emailVerified: emailVerified,
  );

  /// Applies the editable parts of [profile] onto this payload.
  UserProfileDto withEdits(UserProfile profile) {
    final (first, last) = splitFullName(profile.fullName);
    final digits = PhoneNumber.nationalDigits(profile.phone);
    return copyWith(
      firstName: first,
      lastName: last,
      phoneCountryCode: digits.isEmpty ? null : PhoneNumber.countryCode,
      phoneNumber: digits.isEmpty ? null : digits,
    );
  }
}

extension ProfileDetailsMapper on UserProfileDto {
  ProfileDetails toDetails() => ProfileDetails(
    firstName: firstName ?? '',
    lastName: lastName ?? '',
    email: email,
    phone: PhoneNumber.format(phoneCountryCode, phoneNumber),
    phoneVerified: phoneVerified ?? false,
    gender: gender,
    dateOfBirth: switch (dateOfBirth) {
      final date? => DateTime.tryParse(date),
      null => null,
    },
    location: {
      GeoLevel.country: ?countryId,
      GeoLevel.province: ?stateId,
      GeoLevel.city: ?cityId,
      GeoLevel.town: ?townId,
      GeoLevel.area: ?areaId,
    },
    address: address ?? '',
  );

  /// This payload with [details] applied (`PUT /profile` replaces it all).
  UserProfileDto withDetails(ProfileDetails details) {
    final birth = details.dateOfBirth;
    return copyWith(
      firstName: details.firstName.trim(),
      lastName: details.lastName.trim(),
      gender: details.gender,
      dateOfBirth: birth == null
          ? null
          : '${birth.year.toString().padLeft(4, '0')}-'
                '${birth.month.toString().padLeft(2, '0')}-'
                '${birth.day.toString().padLeft(2, '0')}',
      countryId: details.location[GeoLevel.country],
      stateId: details.location[GeoLevel.province],
      cityId: details.location[GeoLevel.city],
      townId: details.location[GeoLevel.town],
      areaId: details.location[GeoLevel.area],
      address: details.address.trim(),
    );
  }
}

/// "Ayesha Khan" → ("Ayesha", "Khan"); "Ayesha Bibi Khan" →
/// ("Ayesha", "Bibi Khan"); a single word becomes the first name.
(String, String) splitFullName(String fullName) {
  final parts = fullName.trim().split(RegExp(r'\s+'));
  if (parts.isEmpty || parts.first.isEmpty) return ('', '');
  return (parts.first, parts.skip(1).join(' '));
}
