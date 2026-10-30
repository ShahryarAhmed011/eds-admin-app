import 'package:eds_admin_app/core/core.dart';
import 'package:eds_admin_app/features/shared/location/data/dto/geo_item_dto.dart';
import 'package:eds_admin_app/features/shared/location/data/mappers/location_mappers.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('country (no serviceability, int id)', () {
    final option = GeoItemDto.fromJson(const {
      'id': 1,
      'iso2': 'PK',
      'iso3': 'PAK',
      'name': 'Pakistan',
      'phoneCode': '92',
      'currencyCode': 'PKR',
      'currencyMinorUnit': 2,
      'timezone': 'Asia/Karachi',
    }).toEntity();

    expect(option.id, '1');
    expect(option.name, 'Pakistan');
    expect(option.served, isNull);
    expect(option.isUnserved, isFalse);
    expect(option.point, isNull);
  });

  test('city carries its centre point', () {
    final option = GeoItemDto.fromJson(const {
      'id': 3,
      'name': 'Islamabad',
      'latitude': 33.6844,
      'longitude': 73.0479,
      'isServiceable': false,
    }).toEntity();

    expect(option.id, '3');
    expect(option.point, const GeoPoint(33.6844, 73.0479));
    expect(option.isUnserved, isTrue);
  });

  test('area serviceability', () {
    final served = GeoItemDto.fromJson(const {
      'id': 411,
      'townId': 41,
      'name': 'G-11/3',
      'postalCode': '44000',
      'isServiceable': true,
    });

    expect(served.postalCode, '44000');
    expect(served.toEntity().served, isTrue);
  });
}
