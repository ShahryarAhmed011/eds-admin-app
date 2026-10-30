import '../../../../../core/core.dart';
import '../dto/geo_item_dto.dart';
import 'location_data_source.dart';

/// Offline cascade in the API's JSON shape (integer ids), with the Figma
/// place names.
class LocationDummyDataSource implements LocationDataSource {
  static const _countries = [
    {
      'id': 1,
      'iso2': 'PK',
      'iso3': 'PAK',
      'name': 'Pakistan',
      'phoneCode': '92',
      'currencyCode': 'PKR',
      'currencyMinorUnit': 2,
      'timezone': 'Asia/Karachi',
    },
  ];

  static const _provinces = [
    {
      'id': 5,
      'countryId': 1,
      'code': 'PK-IS',
      'name': 'Islamabad Capital Territory',
      'type': 'capital_territory',
    },
    {
      'id': 1,
      'countryId': 1,
      'code': 'PK-PB',
      'name': 'Punjab',
      'type': 'province',
    },
    {
      'id': 2,
      'countryId': 1,
      'code': 'PK-SD',
      'name': 'Sindh',
      'type': 'province',
    },
  ];

  static const _cities = [
    {
      'id': 3,
      'name': 'Islamabad',
      'latitude': 33.6844,
      'longitude': 73.0479,
      'isServiceable': true,
    },
    {
      'id': 7,
      'name': 'Rawalpindi',
      'latitude': 33.5651,
      'longitude': 73.0169,
      'isServiceable': false,
    },
  ];

  static const _towns = [
    {'id': 41, 'cityId': 3, 'name': 'G-11', 'isServiceable': true},
    {'id': 39, 'cityId': 3, 'name': 'F-10', 'isServiceable': true},
    {'id': 40, 'cityId': 3, 'name': 'G-10', 'isServiceable': true},
  ];

  static const _areas = [
    {
      'id': 411,
      'townId': 41,
      'name': 'G-11/3',
      // Areas carry no coordinates on the API; the dummy adds them so
      // picking an area moves discovery somewhere visibly different.
      'latitude': 33.6687,
      'longitude': 72.9974,
      'postalCode': '44000',
      'isServiceable': true,
    },
    {
      'id': 412,
      'townId': 41,
      'name': 'G-11/4',
      'latitude': 33.6655,
      'longitude': 72.989,
      'postalCode': '44000',
      'isServiceable': true,
    },
    {
      'id': 413,
      'townId': 41,
      'name': 'G-11 Markaz',
      'latitude': 33.6668,
      'longitude': 72.993,
      'postalCode': '44000',
      'isServiceable': true,
    },
    {
      'id': 499,
      'townId': 41,
      'name': 'Taxila',
      'latitude': 33.7463,
      'longitude': 72.8397,
      'postalCode': '47080',
      'isServiceable': false,
    },
  ];

  @override
  Future<List<GeoItemDto>> fetchCountries() => _list(_countries);

  @override
  Future<List<GeoItemDto>> fetchProvinces(String countryId) =>
      _list(_provinces);

  @override
  Future<List<GeoItemDto>> fetchCities(String provinceId) => _list(_cities);

  @override
  Future<List<GeoItemDto>> fetchTowns(String cityId) => _list(_towns);

  @override
  Future<List<GeoItemDto>> fetchAreas(String townId) => _list(_areas);

  @override
  Future<String?> fetchContactPhone() async => '+92 300 1234567';

  @override
  Future<void> requestAvailabilityUpdates(String phone) => dummyDelay();

  Future<List<GeoItemDto>> _list(List<Map<String, Object>> items) async {
    await dummyDelay();
    return [for (final item in items) GeoItemDto.fromJson(item)];
  }
}
