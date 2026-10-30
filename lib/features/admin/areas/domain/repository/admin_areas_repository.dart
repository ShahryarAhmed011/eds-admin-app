import '../entities/service_area.dart';

abstract interface class AdminAreasRepository {
  Future<ServiceAreaScope> getScope();

  /// Returns the area as saved by the server.
  Future<ServiceArea> setServiceability({
    required ServiceArea area,
    required bool serviceable,
    required String reason,
  });
}
