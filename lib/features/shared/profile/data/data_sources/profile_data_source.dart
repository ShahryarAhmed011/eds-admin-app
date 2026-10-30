import 'dart:typed_data';

import '../../../../../core/core.dart';
import '../dto/user_profile_dto.dart';

abstract interface class ProfileDataSource {
  /// `GET /profile`
  Future<UserProfileDto> fetchProfile();

  /// `PUT /profile`
  Future<UserProfileDto> updateProfile(Json body);

  /// `PUT /profile/image` with the picture as base64.
  Future<void> uploadImage(String base64);

  /// `GET /profile/image`: the picture's bytes, or null when none is set.
  Future<Uint8List?> fetchImage();

  /// `DELETE /profile/image`.
  Future<void> deleteImage();
}
