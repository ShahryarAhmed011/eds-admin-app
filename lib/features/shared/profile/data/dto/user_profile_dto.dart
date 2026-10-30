import '../../../../../core/core.dart';

/// `data` of `GET /profile` and `PUT /profile`.
class UserProfileDto {
  const UserProfileDto({
    required this.id,
    required this.email,
    required this.role,
    this.firstName,
    this.lastName,
    this.phoneCountryCode,
    this.phoneNumber,
    this.phoneVerified,
    this.emailVerified,
    this.hasProfileImage = false,
    this.username,
    this.dateOfBirth,
    this.gender,
    this.profileImageUrl,
    this.countryId,
    this.stateId,
    this.cityId,
    this.townId,
    this.areaId,
    this.postalCode,
    this.cityName,
    this.address,
  });

  factory UserProfileDto.fromJson(Json json) => UserProfileDto(
    id: json.id(),
    email: json.strOr('email'),
    role: json.strOr('role', AppRole.customer.apiValue),
    firstName: json.str('firstName'),
    lastName: json.str('lastName'),
    phoneCountryCode: json.str('phoneCountryCode'),
    phoneNumber: json.str('phoneNumber'),
    phoneVerified: json.containsKey('isPhoneVerified')
        ? json.boolean('isPhoneVerified')
        : json.containsKey('phoneVerified')
        ? json.boolean('phoneVerified')
        : null,
    emailVerified: json.containsKey('isEmailVerified')
        ? json.boolean('isEmailVerified')
        : null,
    hasProfileImage: json.boolean('hasProfileImage'),
    username: json.str('username'),
    dateOfBirth: json.str('dateOfBirth'),
    gender: json.str('gender'),
    profileImageUrl: json.str('profileImageUrl'),
    countryId: json.str('countryId'),
    stateId: json.str('stateId'),
    cityId: json.str('cityId'),
    townId: json.str('townId'),
    areaId: json.str('areaId'),
    postalCode: json.str('postalCode'),
    cityName: json.obj('city')?.str('name') ?? json.str('cityName'),
    address: json.str('address'),
  );

  final String id;
  final String email;
  final String role;
  final String? firstName;
  final String? lastName;
  final String? phoneCountryCode;
  final String? phoneNumber;
  final bool? phoneVerified;
  final bool? emailVerified;

  /// A picture is set (`GET /profile/image`).
  final bool hasProfileImage;
  final String? username;
  final String? dateOfBirth;
  final String? gender;
  final String? profileImageUrl;
  final String? countryId;
  final String? stateId;
  final String? cityId;
  final String? townId;
  final String? areaId;
  final String? postalCode;
  final String? cityName;

  /// The customer's house / street, required for every profile and sent on
  /// `PUT /profile` (and read back from `GET /profile`).
  final String? address;

  UserProfileDto copyWith({
    String? firstName,
    String? lastName,
    String? phoneCountryCode,
    String? phoneNumber,
    String? dateOfBirth,
    String? gender,
    String? countryId,
    String? stateId,
    String? cityId,
    String? townId,
    String? areaId,
    String? address,
    bool? hasProfileImage,
  }) => UserProfileDto(
    id: id,
    email: email,
    role: role,
    firstName: firstName ?? this.firstName,
    lastName: lastName ?? this.lastName,
    phoneCountryCode: phoneCountryCode ?? this.phoneCountryCode,
    phoneNumber: phoneNumber ?? this.phoneNumber,
    phoneVerified: phoneVerified,
    emailVerified: emailVerified,
    hasProfileImage: hasProfileImage ?? this.hasProfileImage,
    username: username,
    dateOfBirth: dateOfBirth ?? this.dateOfBirth,
    gender: gender ?? this.gender,
    profileImageUrl: profileImageUrl,
    countryId: countryId ?? this.countryId,
    stateId: stateId ?? this.stateId,
    cityId: cityId ?? this.cityId,
    townId: townId ?? this.townId,
    areaId: areaId ?? this.areaId,
    postalCode: postalCode,
    cityName: cityName,
    address: address ?? this.address,
  );

  /// Everything read, for the on-device cache (read back by [fromJson]).
  Json toJson() => {
    'id': id,
    'email': email,
    'role': role,
    ...toUpdateJson(),
    'isPhoneVerified': ?phoneVerified,
    'isEmailVerified': ?emailVerified,
    'hasProfileImage': hasProfileImage,
    'cityName': ?cityName,
    'address': ?address,
  };

  /// `PUT /profile` replaces the profile, so every known writable field is
  /// sent back unchanged alongside the edits.
  Json toUpdateJson() => {
    'phoneCountryCode': ?phoneCountryCode,
    'phoneNumber': ?phoneNumber,
    'firstName': ?firstName,
    'lastName': ?lastName,
    'username': ?username,
    'dateOfBirth': ?dateOfBirth,
    'gender': ?gender,
    'profileImageUrl': ?profileImageUrl,
    // The API takes location ids as integers.
    'countryId': ?_int(countryId),
    'stateId': ?_int(stateId),
    'cityId': ?_int(cityId),
    'townId': ?_int(townId),
    'areaId': ?_int(areaId),
    'postalCode': ?postalCode,
    'address': ?address,
  };

  static int? _int(String? id) => id == null ? null : int.tryParse(id);
}
