import '../dto/geo_item_dto.dart';

/// The `/geo` location cascade.
abstract interface class LocationDataSource {
  /// `GET /geo/countries`
  Future<List<GeoItemDto>> fetchCountries();

  /// `GET /geo/countries/{id}/provinces`
  Future<List<GeoItemDto>> fetchProvinces(String countryId);

  /// `GET /geo/provinces/{id}/cities`
  Future<List<GeoItemDto>> fetchCities(String provinceId);

  /// `GET /geo/cities/{id}/towns`
  Future<List<GeoItemDto>> fetchTowns(String cityId);

  /// `GET /geo/towns/{id}/areas`
  Future<List<GeoItemDto>> fetchAreas(String townId);

  /// Number to prefill for "notify me". No endpoint; null against the API.
  Future<String?> fetchContactPhone();

  /// "Notify me when available". No endpoint yet.
  Future<void> requestAvailabilityUpdates(String phone);
}
