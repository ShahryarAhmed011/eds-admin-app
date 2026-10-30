import '../../../../../core/core.dart';
import '../dto/service_area_dto.dart';
import 'admin_areas_data_source.dart';

/// Prefilled data matching the Figma serviceable areas screen, in the geo
/// API's shape plus the impact counts the API does not provide yet.
class AdminAreasDummyDataSource implements AdminAreasDataSource {
  final Map<String, Json> _areas = {
    for (final area in const [
      {
        'id': 'G-11/1',
        'townId': 'G-11',
        'name': 'G-11/1',
        'postalCode': '44000',
        'isServiceable': true,
        'shopCount': 12,
        'savedAddressCount': 64,
      },
      {
        'id': 'G-11/2',
        'townId': 'G-11',
        'name': 'G-11/2',
        'postalCode': '44000',
        'isServiceable': true,
        'shopCount': 8,
        'savedAddressCount': 42,
      },
      {
        'id': 'G-11/3',
        'townId': 'G-11',
        'name': 'G-11/3',
        'postalCode': '44000',
        'isServiceable': true,
        'shopCount': 14,
        'savedAddressCount': 83,
      },
      {
        'id': 'G-11/4',
        'townId': 'G-11',
        'name': 'G-11/4',
        'postalCode': '44000',
        'isServiceable': false,
        'shopCount': 0,
        'savedAddressCount': 0,
        'waitlistAvailable': true,
      },
    ])
      area['id']! as String: Map<String, dynamic>.of(area),
  };

  @override
  Future<ServiceAreaScopeDto> fetchScope() async {
    await dummyDelay();
    return ServiceAreaScopeDto.fromJson({
      'country': {'name': 'Pakistan'},
      'province': {'name': 'ICT'},
      'city': {'id': 3, 'name': 'Islamabad'},
      'town': {'id': 'G-11', 'name': 'G-11'},
      'areas': _areas.values.toList(),
    });
  }

  @override
  Future<ServiceAreaDto> setServiceability({
    required String areaId,
    required bool serviceable,
  }) async {
    await dummyDelay();
    final area = _areas[areaId];
    if (area == null) {
      throw const ApiException(
        status: 404,
        code: ApiErrorCode.notFound,
        message: 'Area not found.',
      );
    }
    area['isServiceable'] = serviceable;
    return ServiceAreaDto.fromJson(area);
  }
}
