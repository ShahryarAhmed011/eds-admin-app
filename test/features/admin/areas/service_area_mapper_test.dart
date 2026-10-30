import 'package:eds_admin_app/features/admin/areas/data/dto/service_area_dto.dart';
import 'package:eds_admin_app/features/admin/areas/data/mappers/service_area_mapper.dart';
import 'package:eds_admin_app/features/admin/areas/presentation/widgets/service_area_labels.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('maps the public geo cascade into a scope', () {
    final scope = ServiceAreaScopeDto.fromJson({
      'city': {'id': 1, 'name': 'Karachi', 'isServiceable': true},
      'town': {'id': 2, 'cityId': 1, 'name': 'Gulistan-e-Jauhar'},
      'areas': [
        {
          'id': 13,
          'townId': 2,
          'name': 'Block 1',
          'postalCode': '75290',
          'isServiceable': true,
        },
        {
          'id': 14,
          'townId': 2,
          'name': 'Block 7',
          'postalCode': '75290',
          'isServiceable': false,
        },
      ],
    }).toEntity();

    expect(scope.label, 'Karachi · Gulistan-e-Jauhar');
    expect(scope.servedCount, 1);
    final served = scope.areas.first;
    expect(served.id, '13');
    expect(served.title, 'Block 1 · Serviceable');
    expect(served.subtitle, 'Postal code 75290');
    expect(served.impactLabel, isNull);
    expect(scope.areas.last.subtitle, isNull);
  });
}
