import '../../../../../core/core.dart';
import '../dto/service_area_dto.dart';
import 'admin_areas_data_source.dart';

class AdminAreasRemoteDataSource implements AdminAreasDataSource {
  const AdminAreasRemoteDataSource(this._api);

  final ApiClient _api;

  /// Walks the public geo cascade: the first city (serviceable first) →
  /// its first town (serviceable first) → that town's areas.
  @override
  Future<ServiceAreaScopeDto> fetchScope() async {
    final cities = await _api.getItems('/geo/cities');
    if (cities.isEmpty) {
      return const ServiceAreaScopeDto(cityName: '', townName: '', areas: []);
    }
    final city = cities.first;
    final towns = await _api.getItems('/geo/cities/${city.id()}/towns');
    if (towns.isEmpty) {
      return ServiceAreaScopeDto.fromJson({'city': city, 'areas': const []});
    }
    final town = towns.first;
    final areas = await _api.getItems('/geo/towns/${town.id()}/areas');
    return ServiceAreaScopeDto.fromJson({
      'city': city,
      'town': town,
      'areas': areas,
    });
  }

  /// `PATCH /admin/geo/areas/{id}/serviceability`.
  @override
  Future<ServiceAreaDto> setServiceability({
    required String areaId,
    required bool serviceable,
  }) async {
    final data = await _api.patch(
      '/admin/geo/areas/$areaId/serviceability',
      body: {'isServiceable': serviceable},
    );
    return ServiceAreaDto.fromJson(
      data is Map ? data.cast<String, dynamic>() : {'id': areaId},
    );
  }
}
