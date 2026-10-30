import 'dart:typed_data';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/core.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/usecase/get_profile.dart';
import '../../domain/usecase/profile_details_usecases.dart';
import '../../domain/usecase/update_profile.dart';

part 'profile_event.dart';
part 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  /// Shown once a save succeeds.
  static const savedMessage = 'Profile saved';

  /// The API takes photos up to 512 KB.
  static const maxPhotoBytes = 512 * 1024;

  ProfileBloc(
    this._getProfile,
    this._updateProfile,
    this._getImage,
    this._uploadImage,
    this._removeImage,
  ) : super(const ProfileLoading()) {
    on<ProfileRequested>(_onRequested);
    on<ProfilePhotoPicked>(_onPhotoPicked);
    on<ProfilePhotoRemoved>(_onPhotoRemoved);
    on<ProfileChanged>(_onChanged);
    on<ProfileSaveRequested>(_onSaveRequested);
  }

  final GetProfile _getProfile;
  final UpdateProfile _updateProfile;
  final GetProfileImage _getImage;
  final UploadProfileImage _uploadImage;
  final RemoveProfileImage _removeImage;

  Future<void> _onRequested(
    ProfileRequested event,
    Emitter<ProfileState> emit,
  ) async {
    emit(const ProfileLoading());
    try {
      final profile = await _getProfile(const NoParams());
      // The photo is a nice-to-have; the form opens without it.
      Uint8List? photo;
      try {
        photo = await _getImage(const NoParams());
      } catch (_) {}
      emit(ProfileLoaded(saved: profile, draft: profile, photo: photo));
    } catch (e) {
      emit(ProfileFailure(errorMessage(e), reference: errorReference(e)));
    }
  }

  void _onChanged(ProfileChanged event, Emitter<ProfileState> emit) {
    final current = state;
    if (current is! ProfileLoaded) return;
    emit(
      current.copyWith(
        draft: current.draft.copyWith(
          fullName: event.fullName,
          phone: event.phone,
          language: event.language,
        ),
      ),
    );
  }

  Future<void> _onSaveRequested(
    ProfileSaveRequested event,
    Emitter<ProfileState> emit,
  ) async {
    final current = state;
    if (current is! ProfileLoaded || current.isSaving) return;
    emit(current.copyWith(isSaving: true));
    try {
      final saved = await _updateProfile(current.draft);
      final next = ProfileLoaded(
        saved: saved,
        draft: saved,
        photo: (state as ProfileLoaded).photo,
      );
      emit(next.copyWith(message: savedMessage));
      emit(next);
    } on ApiException catch (e) {
      if (e.code == ApiErrorCode.phoneInUse) {
        emit(current.copyWith(phoneError: e.message));
      } else {
        emit(current.copyWith(message: errorMessage(e)));
        emit(current);
      }
    } catch (e) {
      emit(current.copyWith(message: errorMessage(e)));
      emit(current);
    }
  }

  /// Uploads right away; the header shows it once the API has it.
  Future<void> _onPhotoPicked(
    ProfilePhotoPicked event,
    Emitter<ProfileState> emit,
  ) async {
    final current = state;
    if (current is! ProfileLoaded || current.isUploadingPhoto) return;
    if (event.bytes.length > maxPhotoBytes) {
      emit(current.copyWith(message: 'That photo is too large. Try another.'));
      emit(current);
      return;
    }
    emit(current.copyWith(isUploadingPhoto: true));
    try {
      await _uploadImage(event.bytes);
      final next = (state as ProfileLoaded).withPhoto(event.bytes);
      emit(next.copyWith(message: photoSavedMessage));
      emit(next);
    } catch (e) {
      final loaded = state as ProfileLoaded;
      emit(loaded.copyWith(message: errorMessage(e)));
      emit(loaded.copyWith());
    }
  }

  Future<void> _onPhotoRemoved(
    ProfilePhotoRemoved event,
    Emitter<ProfileState> emit,
  ) async {
    final current = state;
    if (current is! ProfileLoaded || current.photo == null) return;
    emit(current.copyWith(isUploadingPhoto: true));
    try {
      await _removeImage(const NoParams());
      final next = (state as ProfileLoaded).withPhoto(null);
      emit(next.copyWith(message: photoRemovedMessage));
      emit(next);
    } catch (e) {
      final loaded = state as ProfileLoaded;
      emit(loaded.copyWith(message: errorMessage(e)));
      emit(loaded.copyWith());
    }
  }

  /// Shown once a new photo is uploaded.
  static const photoSavedMessage = 'Photo updated';
  static const photoRemovedMessage = 'Photo removed';
}
