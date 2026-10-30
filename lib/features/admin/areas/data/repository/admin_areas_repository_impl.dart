import '../../domain/entities/service_area.dart';
import '../../domain/repository/admin_areas_repository.dart';
import '../data_sources/admin_areas_data_source.dart';
import '../mappers/service_area_mapper.dart';

class AdminAreasRepositoryImpl implements AdminAreasRepository {
  const AdminAreasRepositoryImpl(this._dataSource);

  final AdminAreasDataSource _dataSource;

  @override
  Future<ServiceAreaScope> getScope() async =>
      (await _dataSource.fetchScope()).toEntity();

  /// The API takes no reason yet; it is kept for the audit trail once the
  /// endpoint accepts one.
  @override
  Future<ServiceArea> setServiceability({
    required ServiceArea area,
    required bool serviceable,
    required String reason,
  }) async {
    final saved = (await _dataSource.setServiceability(
      areaId: area.id,
      serviceable: serviceable,
    )).toEntity();
    // Keep impact counts the PATCH response does not echo back.
    return ServiceArea(
      id: saved.id,
      name: saved.name.isEmpty ? area.name : saved.name,
      isServiceable: saved.isServiceable,
      postalCode: saved.postalCode ?? area.postalCode,
      shopCount: area.shopCount,
      savedAddressCount: area.savedAddressCount,
      waitlistAvailable: area.waitlistAvailable,
    );
  }
}
