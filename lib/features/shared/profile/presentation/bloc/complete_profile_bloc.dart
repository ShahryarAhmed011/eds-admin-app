import 'dart:typed_data';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/core.dart';
import '../../domain/entities/profile_details.dart';
import '../../domain/usecase/profile_details_usecases.dart';

/// "Complete your profile" (onboarding): name, gender, birthday and the
/// location cascade, saved in one go.
class CompleteProfileBloc
    extends Bloc<CompleteProfileEvent, CompleteProfileState> {
  CompleteProfileBloc(
    this._getDetails,
    this._saveDetails,
    this._geoOptions,
    this._getImage,
    this._uploadImage,
    this._removeImage,
  ) : super(const CompleteProfileLoading()) {
    on<CompleteProfilePhotoRemoved>(_onPhotoRemoved);
    on<CompleteProfilePhotoPicked>(_onPhotoPicked);
    on<CompleteProfileStarted>(_onStarted);
    on<CompleteProfileEdited>(_onEdited);
    on<CompleteProfileLocationChosen>(_onLocationChosen);
    on<CompleteProfileSaved>(_onSaved);
  }

  final GetProfileDetails _getDetails;
  final SaveProfileDetails _saveDetails;
  final GetGeoOptions _geoOptions;
  final GetProfileImage _getImage;
  final UploadProfileImage _uploadImage;
  final RemoveProfileImage _removeImage;

  /// The API's limit for a profile picture.
  static const maxPhotoBytes = 512 * 1024;

  Future<void> _onStarted(
    CompleteProfileStarted event,
    Emitter<CompleteProfileState> emit,
  ) async {
    emit(const CompleteProfileLoading());
    try {
      final details = await _getDetails(const NoParams());
      // The country list, then the list under every level already chosen.
      final options = <GeoLevel, List<GeoOption>>{
        GeoLevel.country: await _geoOptions(
          const GeoOptionsParams(GeoLevel.country),
        ),
      };
      for (final level in GeoLevel.values) {
        final chosen = details.location[level];
        final next = level.next;
        if (chosen == null || next == null) break;
        options[next] = await _geoOptions(
          GeoOptionsParams(next, parentId: chosen),
        );
      }
      // An existing picture, best effort.
      Uint8List? photo;
      try {
        photo = await _getImage(const NoParams());
      } catch (_) {}
      emit(
        CompleteProfileReady(details: details, options: options, photo: photo),
      );
    } catch (e) {
      emit(CompleteProfileFailure(errorMessage(e)));
    }
  }

  void _onEdited(
    CompleteProfileEdited event,
    Emitter<CompleteProfileState> emit,
  ) {
    final current = state;
    if (current is! CompleteProfileReady) return;
    emit(
      current.copyWith(
        details: current.details.copyWith(
          firstName: event.firstName,
          lastName: event.lastName,
          gender: event.gender,
          dateOfBirth: event.dateOfBirth,
          address: event.address,
        ),
      ),
    );
  }

  Future<void> _onLocationChosen(
    CompleteProfileLocationChosen event,
    Emitter<CompleteProfileState> emit,
  ) async {
    final current = state;
    if (current is! CompleteProfileReady) return;
    final next = event.level.next;
    // Lists under the changed level no longer apply.
    final options = {
      for (final entry in current.options.entries)
        if (entry.key.index <= event.level.index) entry.key: entry.value,
    };
    final chosen = current.copyWith(
      details: current.details.choose(event.level, event.id),
      options: options,
      loading: next,
    );
    emit(chosen);
    if (next == null) {
      emit(chosen.copyWith(clearLoading: true));
      return;
    }
    try {
      final list = await _geoOptions(
        GeoOptionsParams(next, parentId: event.id),
      );
      final latest = state as CompleteProfileReady;
      emit(
        latest.copyWith(
          options: {...latest.options, next: list},
          clearLoading: true,
        ),
      );
    } catch (e) {
      emit(
        (state as CompleteProfileReady).copyWith(
          clearLoading: true,
          error: errorMessage(e),
        ),
      );
    }
  }

  /// Uploads right away, so the picture is set even before the profile is
  /// saved.
  Future<void> _onPhotoPicked(
    CompleteProfilePhotoPicked event,
    Emitter<CompleteProfileState> emit,
  ) async {
    final current = state;
    if (current is! CompleteProfileReady) return;
    if (event.bytes.length > maxPhotoBytes) {
      emit(current.copyWith(error: 'That photo is too large. Try another.'));
      return;
    }
    emit(current.copyWith(isUploadingPhoto: true));
    try {
      await _uploadImage(event.bytes);
      emit(
        (state as CompleteProfileReady).copyWith(
          photo: event.bytes,
          photoUploaded: true,
        ),
      );
    } catch (e) {
      emit((state as CompleteProfileReady).copyWith(error: errorMessage(e)));
    }
  }

  Future<void> _onPhotoRemoved(
    CompleteProfilePhotoRemoved event,
    Emitter<CompleteProfileState> emit,
  ) async {
    final current = state;
    if (current is! CompleteProfileReady || current.photo == null) return;
    emit(current.copyWith(isUploadingPhoto: true));
    try {
      await _removeImage(const NoParams());
      emit((state as CompleteProfileReady).copyWith(clearPhoto: true));
    } catch (e) {
      emit((state as CompleteProfileReady).copyWith(error: errorMessage(e)));
    }
  }

  Future<void> _onSaved(
    CompleteProfileSaved event,
    Emitter<CompleteProfileState> emit,
  ) async {
    final current = state;
    if (current is! CompleteProfileReady ||
        !current.canSave ||
        current.isSaving) {
      return;
    }
    emit(current.copyWith(isSaving: true));
    try {
      final saved = await _saveDetails(current.details);
      emit(current.copyWith(details: saved, isDone: true));
    } catch (e) {
      emit(current.copyWith(error: errorMessage(e)));
    }
  }
}

sealed class CompleteProfileEvent extends Equatable {
  const CompleteProfileEvent();

  @override
  List<Object?> get props => [];
}

final class CompleteProfileStarted extends CompleteProfileEvent {
  const CompleteProfileStarted();
}

/// Only non-null values are applied.
final class CompleteProfileEdited extends CompleteProfileEvent {
  const CompleteProfileEdited({
    this.firstName,
    this.lastName,
    this.gender,
    this.dateOfBirth,
    this.address,
  });

  final String? firstName;
  final String? lastName;
  final String? gender;
  final DateTime? dateOfBirth;
  final String? address;

  @override
  List<Object?> get props => [
    firstName,
    lastName,
    gender,
    dateOfBirth,
    address,
  ];
}

final class CompleteProfileLocationChosen extends CompleteProfileEvent {
  const CompleteProfileLocationChosen(this.level, this.id);

  final GeoLevel level;
  final String id;

  @override
  List<Object?> get props => [level, id];
}

final class CompleteProfilePhotoPicked extends CompleteProfileEvent {
  const CompleteProfilePhotoPicked(this.bytes);

  final Uint8List bytes;

  @override
  List<Object?> get props => [bytes.length];
}

final class CompleteProfilePhotoRemoved extends CompleteProfileEvent {
  const CompleteProfilePhotoRemoved();
}

final class CompleteProfileSaved extends CompleteProfileEvent {
  const CompleteProfileSaved();
}

sealed class CompleteProfileState extends Equatable {
  const CompleteProfileState();

  @override
  List<Object?> get props => [];
}

final class CompleteProfileLoading extends CompleteProfileState {
  const CompleteProfileLoading();
}

final class CompleteProfileFailure extends CompleteProfileState {
  const CompleteProfileFailure(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}

final class CompleteProfileReady extends CompleteProfileState {
  const CompleteProfileReady({
    required this.details,
    required this.options,
    this.loading,
    this.isSaving = false,
    this.isDone = false,
    this.error,
    this.photo,
    this.isUploadingPhoto = false,
    this.photoUploaded = false,
  });

  final ProfileDetails details;

  /// The profile picture shown; set once uploaded (or loaded).
  final Uint8List? photo;
  final bool isUploadingPhoto;

  /// One-shot: a picked photo was uploaded.
  final bool photoUploaded;

  /// Choices per level; a level is absent until the one above is chosen.
  final Map<GeoLevel, List<GeoOption>> options;

  /// Level whose list is loading.
  final GeoLevel? loading;
  final bool isSaving;

  /// One-shot: saved, move on.
  final bool isDone;

  /// One-shot: shown in a toast.
  final String? error;

  /// The chosen option at [level], when its list has it.
  GeoOption? chosen(GeoLevel level) {
    final id = details.location[level];
    if (id == null) return null;
    for (final option in options[level] ?? const <GeoOption>[]) {
      if (option.id == id) return option;
    }
    return null;
  }

  /// "About you" is done: both names.
  bool get hasName =>
      details.firstName.trim().isNotEmpty && details.lastName.trim().isNotEmpty;

  /// The chosen town has no areas to pick, so only the typed address places
  /// the customer; otherwise an area is picked alongside the address.
  bool get needsAddress =>
      details.location.containsKey(GeoLevel.town) &&
      loading != GeoLevel.area &&
      (options[GeoLevel.area]?.isEmpty ?? false);

  /// "Location" is done: a city, then town / area wherever the lists offer
  /// them, plus a typed street address (the backend requires it for every
  /// profile).
  bool get hasLocation {
    if (!details.location.containsKey(GeoLevel.city)) return false;
    for (final level in const [GeoLevel.town, GeoLevel.area]) {
      final list = options[level];
      if (list == null) {
        // Not loaded: only fine once the level above has no choices.
        if (loading == level) return false;
        continue;
      }
      if (list.isNotEmpty && !details.location.containsKey(level)) {
        return false;
      }
    }
    return details.address.trim().isNotEmpty;
  }

  bool get canSave => hasName && hasLocation;

  CompleteProfileReady copyWith({
    ProfileDetails? details,
    Map<GeoLevel, List<GeoOption>>? options,
    GeoLevel? loading,
    bool clearLoading = false,
    bool isSaving = false,
    bool isDone = false,
    String? error,
    Uint8List? photo,
    bool clearPhoto = false,
    bool isUploadingPhoto = false,
    bool photoUploaded = false,
  }) => CompleteProfileReady(
    details: details ?? this.details,
    options: options ?? this.options,
    loading: clearLoading ? null : loading ?? this.loading,
    isSaving: isSaving,
    isDone: isDone,
    error: error,
    photo: clearPhoto ? null : photo ?? this.photo,
    isUploadingPhoto: isUploadingPhoto,
    photoUploaded: photoUploaded,
  );

  @override
  List<Object?> get props => [
    details,
    options,
    loading,
    isSaving,
    isDone,
    error,
    photo?.length,
    isUploadingPhoto,
    photoUploaded,
  ];
}
