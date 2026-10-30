import '../dto/service_area_dto.dart';

abstract interface class AdminAreasDataSource {
  Future<ServiceAreaScopeDto> fetchScope();

  Future<ServiceAreaDto> setServiceability({
    required String areaId,
    required bool serviceable,
  });
}
