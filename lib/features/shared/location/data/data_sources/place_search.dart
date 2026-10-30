import 'package:dio/dio.dart';

import '../../../../../core/core.dart';

/// One place a search turned up: its own name, the rest of its address,
/// and where it is.
class PlaceHit {
  const PlaceHit({
    required this.name,
    required this.detail,
    required this.point,
  });

  final String name;
  final String detail;
  final GeoPoint point;
}

/// Free-text place search on OpenStreetMap's Nominatim — the same data as
/// the map tiles, no key. Its usage policy asks for a User-Agent and at
/// most one request a second, so callers debounce typing.
class NominatimPlaceSearch {
  NominatimPlaceSearch()
    : _dio = Dio(
        BaseOptions(
          baseUrl: 'https://nominatim.openstreetmap.org',
          headers: const {'User-Agent': 'com.eds.eds_mobile_app'},
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
        ),
      );

  final Dio _dio;

  /// Up to [limit] places in Pakistan matching [query].
  Future<List<PlaceHit>> search(String query, {int limit = 6}) async {
    final response = await _dio.get<List<dynamic>>(
      '/search',
      queryParameters: {
        'q': query,
        'format': 'jsonv2',
        'limit': limit,
        'countrycodes': 'pk',
      },
    );
    return [
      for (final raw in response.data ?? const <dynamic>[])
        if (raw is Map) ?_hit(raw.cast<String, dynamic>()),
    ];
  }

  /// "Sector J, G-11, Islamabad, …" → name "Sector J", detail the rest.
  static PlaceHit? _hit(Json json) {
    final lat = json.decimal('lat');
    final lon = json.decimal('lon');
    final display = json.strOr('display_name');
    if (lat == null || lon == null || display.isEmpty) return null;
    final comma = display.indexOf(',');
    return PlaceHit(
      name: comma < 0 ? display : display.substring(0, comma).trim(),
      detail: comma < 0 ? '' : display.substring(comma + 1).trim(),
      point: GeoPoint(lat, lon),
    );
  }
}
