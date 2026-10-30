import 'dart:typed_data';

import '../entities/profile_details.dart';
import '../entities/user_profile.dart';

abstract interface class ProfileRepository {
  /// The device copy when there is one, otherwise `GET /profile`.
  Future<UserProfile> getProfile();

  /// Saves name and phone to the API and the language locally.
  Future<UserProfile> updateProfile(UserProfile profile);

  /// "Complete your profile": the saved details, with Pakistan and
  /// Islamabad / Rawalpindi chosen when no location is set yet.
  Future<ProfileDetails> getDetails();

  /// Saves [details] (`PUT /profile`), keeps the result on the device and
  /// finishes the onboarding "profile" step.
  Future<ProfileDetails> saveDetails(ProfileDetails details);

  /// The profile picture, or null when none is set.
  Future<Uint8List?> getImage();

  /// Uploads [bytes] as the profile picture (PNG / JPEG / GIF / WEBP, up
  /// to 512 KB).
  Future<void> uploadImage(Uint8List bytes);

  /// Removes the profile picture.
  Future<void> removeImage();

  /// Choices for [level]; [parentId] is the level above's choice (none for
  /// countries).
  Future<List<GeoOption>> geoOptions(GeoLevel level, {String? parentId});
}
