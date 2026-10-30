import '../../../../../core/core.dart';
import '../dto/geo_item_dto.dart';
import 'location_data_source.dart';

class LocationRemoteDataSource implements LocationDataSource {
  const LocationRemoteDataSource(this._api);

  final ApiClient _api;

  @override
  Future<List<GeoItemDto>> fetchCountries() => _list('/geo/countries');

  @override
  Future<List<GeoItemDto>> fetchProvinces(String countryId) =>
      _list('/geo/countries/$countryId/provinces');

  @override
  Future<List<GeoItemDto>> fetchCities(String provinceId) =>
      _list('/geo/provinces/$provinceId/cities');

  @override
  Future<List<GeoItemDto>> fetchTowns(String cityId) =>
      _list('/geo/cities/$cityId/towns');

  @override
  Future<List<GeoItemDto>> fetchAreas(String townId) =>
      _list('/geo/towns/$townId/areas');

  @override
  Future<String?> fetchContactPhone() async => null;

  @override
  Future<void> requestAvailabilityUpdates(String phone) async {}

  Future<List<GeoItemDto>> _list(String path) async => [
    for (final item in await _api.getItems(path)) GeoItemDto.fromJson(item),
  ];
}
