part of 'profile_bloc.dart';

sealed class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object?> get props => [];
}

final class ProfileRequested extends ProfileEvent {
  const ProfileRequested();
}

/// Any field edit. Only non-null values are applied.
final class ProfileChanged extends ProfileEvent {
  const ProfileChanged({this.fullName, this.phone, this.language});

  final String? fullName;
  final String? phone;
  final String? language;

  @override
  List<Object?> get props => [fullName, phone, language];
}

final class ProfileSaveRequested extends ProfileEvent {
  const ProfileSaveRequested();
}

/// A new profile picture to upload.
final class ProfilePhotoPicked extends ProfileEvent {
  const ProfilePhotoPicked(this.bytes);

  final Uint8List bytes;

  @override
  List<Object?> get props => [bytes];
}

final class ProfilePhotoRemoved extends ProfileEvent {
  const ProfilePhotoRemoved();
}
