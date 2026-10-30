import 'dart:typed_data';

import '../../../../../core/core.dart';
import '../dto/user_profile_dto.dart';
import 'profile_data_source.dart';

class ProfileRemoteDataSource implements ProfileDataSource {
  const ProfileRemoteDataSource(this._api);

  final ApiClient _api;

  @override
  Future<UserProfileDto> fetchProfile() async =>
      UserProfileDto.fromJson(await _api.getObject('/profile'));

  @override
  Future<void> uploadImage(String base64) =>
      _api.put('/profile/image', body: {'image': base64});

  @override
  Future<Uint8List?> fetchImage() => _api.getBytes('/profile/image');

  @override
  Future<void> deleteImage() => _api.delete('/profile/image');

  @override
  Future<UserProfileDto> updateProfile(Json body) async {
    final data = await _api.put('/profile', body: body);
    return UserProfileDto.fromJson(
      data is Map ? data.cast<String, dynamic>() : body,
    );
  }
}
