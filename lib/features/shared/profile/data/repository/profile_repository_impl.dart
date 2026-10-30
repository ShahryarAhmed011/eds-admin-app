import 'dart:convert';
import 'dart:typed_data';

import '../../../../../core/core.dart';
import '../../../location/data/data_sources/location_data_source.dart';
import '../../domain/entities/profile_details.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/repository/profile_repository.dart';
import '../data_sources/profile_data_source.dart';
import '../dto/user_profile_dto.dart';
import '../mappers/user_profile_mapper.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  ProfileRepositoryImpl(
    this._dataSource, [
    this._onboarding,
    this._cache,
    this._geo,
  ]);

  final ProfileDataSource _dataSource;

  /// A saved profile finishes the onboarding "profile" step.
  final OnboardingTracker? _onboarding;

  /// The profile on the device, so it isn't refetched (cleared on sign
  /// out).
  final SessionCache? _cache;

  /// The `/geo` location lists.
  final LocationDataSource? _geo;

  static const _languages = ['English', 'Urdu'];

  /// Preferred language is device-local; the API has no field for it.
  String _language = _languages.first;

  /// Last payload when there is no device cache (tests), so a save can
  /// send back untouched fields. With a cache, the cache is the source:
  /// login refreshes it and sign out clears it, so nothing stale is kept
  /// in memory across accounts.
  UserProfileDto? _last;

  /// Location lists already loaded, by level and parent.
  final _geoLists = <String, List<GeoOption>>{};

  @override
  Future<UserProfile> getProfile() async => _map(await _load());

  @override
  Future<UserProfile> updateProfile(UserProfile profile) async {
    final saved = await _save((await _load()).withEdits(profile));
    _language = profile.language;
    return _map(saved);
  }

  /// Gender and birthday preset when not set yet: male, and exactly 18
  /// years ago (the youngest a shop or rider can be).
  @override
  Future<ProfileDetails> getDetails() async {
    var details = (await _load()).toDetails();
    details = details.copyWith(
      gender: details.gender ?? 'male',
      dateOfBirth: details.dateOfBirth ?? yearsAgo(18),
    );
    if (details.location.containsKey(GeoLevel.country)) return details;
    return details.copyWith(location: await _defaultLocation());
  }

  @override
  Future<ProfileDetails> saveDetails(ProfileDetails details) async {
    final edited = (await _load()).withDetails(details);
    final saved = await _save(edited);
    // The API doesn't keep the address; the device copy does.
    final withAddress = saved.copyWith(address: edited.address);
    await _cache?.write(SessionCacheKeys.profile, withAddress.toJson());
    return withAddress.toDetails();
  }

  @override
  Future<Uint8List?> getImage() async {
    final hasPhoto = (await _load()).hasProfileImage;
    final cache = _cache;
    if (cache == null) return hasPhoto ? _dataSource.fetchImage() : null;
    return ProfilePhotoCache(
      cache,
    ).get(hasPhoto: hasPhoto, fetch: _dataSource.fetchImage);
  }

  @override
  Future<void> uploadImage(Uint8List bytes) async {
    await _dataSource.uploadImage(base64Encode(bytes));
    // The device copy now knows there's a picture.
    final updated = (await _load()).copyWith(hasProfileImage: true);
    await _cache?.write(SessionCacheKeys.profile, updated.toJson());
    if (_cache case final cache?) await ProfilePhotoCache(cache).write(bytes);
    if (_cache == null) _last = updated;
  }

  @override
  Future<void> removeImage() async {
    await _dataSource.deleteImage();
    final updated = (await _load()).copyWith(hasProfileImage: false);
    await _cache?.write(SessionCacheKeys.profile, updated.toJson());
    if (_cache case final cache?) await ProfilePhotoCache(cache).write(null);
    if (_cache == null) _last = updated;
  }

  @override
  Future<List<GeoOption>> geoOptions(GeoLevel level, {String? parentId}) async {
    final geo = _geo;
    if (geo == null) return const [];
    final key = '${level.name}:${parentId ?? ''}';
    if (_geoLists[key] case final cached?) return cached;
    final items = await switch (level) {
      GeoLevel.country => geo.fetchCountries(),
      GeoLevel.province => geo.fetchProvinces(parentId!),
      GeoLevel.city => geo.fetchCities(parentId!),
      GeoLevel.town => geo.fetchTowns(parentId!),
      GeoLevel.area => geo.fetchAreas(parentId!),
    };
    return _geoLists[key] = [
      for (final item in items) GeoOption(id: item.id, name: item.name),
    ];
  }

  /// The device copy, else `GET /profile` (then kept on the device).
  Future<UserProfileDto> _load() async {
    final cache = _cache;
    if (cache == null) return _last ??= await _dataSource.fetchProfile();
    if (await cache.read(SessionCacheKeys.profile) case final cached?) {
      return UserProfileDto.fromJson(cached);
    }
    final fetched = await _dataSource.fetchProfile();
    await cache.write(SessionCacheKeys.profile, fetched.toJson());
    return fetched;
  }

  /// `PUT /profile`, then the device copy and the onboarding step.
  Future<UserProfileDto> _save(UserProfileDto profile) async {
    final saved = await _dataSource.updateProfile(profile.toUpdateJson());
    await _cache?.write(SessionCacheKeys.profile, saved.toJson());
    await _onboarding?.completeOnboarding(OnboardingStep.profile);
    return _last = saved;
  }

  /// Pakistan → Islamabad Capital Territory → Islamabad → DHA Phase 2, as
  /// far as the lists allow (Punjab / Rawalpindi when there's no
  /// Islamabad). Best effort: an empty choice on failure.
  Future<Map<GeoLevel, String>> _defaultLocation() async {
    final chosen = <GeoLevel, String>{};
    try {
      final country = _pick(await geoOptions(GeoLevel.country), ['pakistan']);
      if (country == null) return chosen;
      chosen[GeoLevel.country] = country.id;
      final provinces = await geoOptions(
        GeoLevel.province,
        parentId: country.id,
      );
      // Islamabad Capital Territory first, else Punjab (Rawalpindi).
      for (final province in [
        ?_pick(provinces, ['islamabad']),
        ?_pick(provinces, ['punjab']),
      ]) {
        final cities = await geoOptions(GeoLevel.city, parentId: province.id);
        final city = _pick(cities, ['islamabad', 'rawalpindi']);
        if (city == null) continue;
        chosen[GeoLevel.province] = province.id;
        chosen[GeoLevel.city] = city.id;
        final towns = await geoOptions(GeoLevel.town, parentId: city.id);
        final town = _pick(towns, ['dha phase 2', 'dha phase ii', 'dha']);
        if (town != null) chosen[GeoLevel.town] = town.id;
        break;
      }
    } catch (_) {
      // Lists unavailable: the user picks by hand.
    }
    return chosen;
  }

  static GeoOption? _pick(List<GeoOption> options, List<String> names) {
    for (final name in names) {
      for (final option in options) {
        if (option.name.toLowerCase().contains(name)) return option;
      }
    }
    return null;
  }

  UserProfile _map(UserProfileDto dto) =>
      dto.toEntity(language: _language, availableLanguages: _languages);
}
