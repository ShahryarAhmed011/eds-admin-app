import 'dart:typed_data';

import '../../../../../core/core.dart';
import '../entities/profile_details.dart';
import '../repository/profile_repository.dart';

class GetProfileDetails implements UseCase<ProfileDetails, NoParams> {
  const GetProfileDetails(this._repository);

  final ProfileRepository _repository;

  @override
  Future<ProfileDetails> call(NoParams params) => _repository.getDetails();
}

class SaveProfileDetails implements UseCase<ProfileDetails, ProfileDetails> {
  const SaveProfileDetails(this._repository);

  final ProfileRepository _repository;

  @override
  Future<ProfileDetails> call(ProfileDetails params) =>
      _repository.saveDetails(params);
}

class GeoOptionsParams {
  const GeoOptionsParams(this.level, {this.parentId});

  final GeoLevel level;
  final String? parentId;
}

class GetGeoOptions implements UseCase<List<GeoOption>, GeoOptionsParams> {
  const GetGeoOptions(this._repository);

  final ProfileRepository _repository;

  @override
  Future<List<GeoOption>> call(GeoOptionsParams params) =>
      _repository.geoOptions(params.level, parentId: params.parentId);
}

class GetProfileImage implements UseCase<Uint8List?, NoParams> {
  const GetProfileImage(this._repository);

  final ProfileRepository _repository;

  @override
  Future<Uint8List?> call(NoParams params) => _repository.getImage();
}

class UploadProfileImage implements UseCase<void, Uint8List> {
  const UploadProfileImage(this._repository);

  final ProfileRepository _repository;

  @override
  Future<void> call(Uint8List params) => _repository.uploadImage(params);
}

class RemoveProfileImage implements UseCase<void, NoParams> {
  const RemoveProfileImage(this._repository);

  final ProfileRepository _repository;

  @override
  Future<void> call(NoParams params) => _repository.removeImage();
}
