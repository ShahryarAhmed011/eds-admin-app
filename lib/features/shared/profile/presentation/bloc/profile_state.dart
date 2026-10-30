part of 'profile_bloc.dart';

sealed class ProfileState extends Equatable {
  const ProfileState();

  @override
  List<Object?> get props => [];
}

final class ProfileLoading extends ProfileState {
  const ProfileLoading();
}

final class ProfileLoaded extends ProfileState {
  const ProfileLoaded({
    required this.saved,
    required this.draft,
    this.isSaving = false,
    this.phoneError,
    this.message,
    this.photo,
    this.isUploadingPhoto = false,
  });

  /// The profile picture, when there is one.
  final Uint8List? photo;
  final bool isUploadingPhoto;

  /// Last persisted profile, shown in the summary card.
  final UserProfile saved;

  /// Values currently in the form.
  final UserProfile draft;
  final bool isSaving;
  final String? phoneError;

  /// One-shot snackbar text ("Profile saved" or a save failure).
  final String? message;

  bool get hasChanges => saved != draft;

  /// Clears [phoneError] and [message] unless given.
  ProfileLoaded copyWith({
    UserProfile? draft,
    bool isSaving = false,
    String? phoneError,
    String? message,
    bool isUploadingPhoto = false,
  }) => ProfileLoaded(
    saved: saved,
    draft: draft ?? this.draft,
    isSaving: isSaving,
    phoneError: phoneError,
    message: message,
    photo: photo,
    isUploadingPhoto: isUploadingPhoto,
  );

  ProfileLoaded withPhoto(Uint8List? photo) =>
      ProfileLoaded(saved: saved, draft: draft, photo: photo);

  @override
  List<Object?> get props => [
    saved,
    draft,
    isSaving,
    phoneError,
    message,
    photo,
    isUploadingPhoto,
  ];
}

final class ProfileFailure extends ProfileState {
  const ProfileFailure(this.message, {this.reference});

  final String message;
  final String? reference;

  @override
  List<Object?> get props => [message, reference];
}
