import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../../core/core.dart';

/// What the user chose in [pickProfilePhoto].
sealed class ProfilePhotoChoice {
  const ProfilePhotoChoice();
}

/// A new photo, already scaled down.
final class ProfilePhotoPicked extends ProfilePhotoChoice {
  const ProfilePhotoPicked(this.bytes);

  final Uint8List bytes;
}

/// Delete the current photo.
final class ProfilePhotoRemove extends ProfilePhotoChoice {
  const ProfilePhotoRemove();
}

/// Camera, library or (with [hasPhoto], unless [allowRemove] is off — a
/// store must keep a picture) "Remove photo"; the picture is kept small
/// (the API takes up to 512 KB). [camera] is the one that opens first: the
/// front one for a profile picture. Null when dismissed.
Future<ProfilePhotoChoice?> pickProfilePhoto(
  BuildContext context, {
  required bool hasPhoto,
  bool allowRemove = true,
  CameraDevice camera = CameraDevice.front,
}) async {
  // null: dismissed; 'remove': delete the current photo.
  final source = await showModalBottomSheet<Object>(
    context: context,
    backgroundColor: AppColors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(AppRadius.sheet),
      ),
    ),
    builder: (context) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(
              Icons.photo_camera_outlined,
              color: AppColors.crimson,
            ),
            title: const Text('Take a photo'),
            onTap: () => Navigator.of(context).pop(ImageSource.camera),
          ),
          ListTile(
            leading: const Icon(
              Icons.photo_library_outlined,
              color: AppColors.crimson,
            ),
            title: const Text('Choose from library'),
            onTap: () => Navigator.of(context).pop(ImageSource.gallery),
          ),
          if (hasPhoto && allowRemove)
            ListTile(
              leading: const Icon(
                Icons.delete_outline,
                color: AppColors.crimson,
              ),
              title: const Text('Remove photo'),
              onTap: () => Navigator.of(context).pop('remove'),
            ),
        ],
      ),
    ),
  );
  if (source == null) return null;
  if (source is! ImageSource) return const ProfilePhotoRemove();
  final file = await ImagePicker().pickImage(
    source: source,
    maxWidth: 800,
    maxHeight: 800,
    imageQuality: 75,
    preferredCameraDevice: camera,
  );
  if (file == null) return null;
  return ProfilePhotoPicked(await file.readAsBytes());
}
