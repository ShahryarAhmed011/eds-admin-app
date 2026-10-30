import 'dart:convert';
import 'dart:typed_data';

import '../../../../../core/core.dart';
import '../dto/user_profile_dto.dart';
import 'profile_data_source.dart';

/// Offline profile in the API's JSON shape, with the Figma values.
class ProfileDummyDataSource implements ProfileDataSource {
  Json _profile = {
    'id': 101,
    'email': 'ayesha.k@example.com',
    'active': true,
    'createdAt': '2026-08-22T15:00:00Z',
    'phoneCountryCode': '+92',
    'phoneNumber': '3001234567',
    'phoneVerified': true,
    'firstName': 'Ayesha',
    'lastName': 'Khan',
    'username': 'ayeshak',
    'role': 'customer',
    'dateOfBirth': null,
    'gender': null,
    'cityId': 3,
    'city': {'id': 3, 'name': 'Islamabad'},
  };

  @override
  Future<UserProfileDto> fetchProfile() async {
    await dummyDelay();
    return UserProfileDto.fromJson(_profile);
  }

  @override
  Future<UserProfileDto> updateProfile(Json body) async {
    await dummyDelay();
    _profile = {..._profile, ...body};
    return UserProfileDto.fromJson(_profile);
  }

  Uint8List? _image;

  @override
  Future<void> uploadImage(String base64) async =>
      _image = base64Decode(base64);

  @override
  Future<Uint8List?> fetchImage() async => _image;

  @override
  Future<void> deleteImage() async => _image = null;
}
