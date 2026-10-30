import 'package:eds_admin_app/core/core.dart';
import 'package:eds_admin_app/features/admin/more/data/dto/admin_profile_dto.dart';
import 'package:eds_admin_app/features/admin/more/data/mappers/admin_profile_mapper.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('maps GET /profile', () {
    final p = AdminProfileDto.fromJson(const {
      'id': 7,
      'email': 'nadia@example.com',
      'active': true,
      'role': 'admin',
      'firstName': 'Nadia',
      'lastName': 'Ahmed',
      'phoneCountryCode': '+92',
      'phoneNumber': '3009876543',
      'city': 'Islamabad',
    }).toEntity(pendingProductRequests: 7);
    expect(p.fullName, 'Nadia Ahmed');
    expect(p.role, AppRole.admin);
    expect(p.phone, '+92 300 9876543');
    expect(p.city, 'Islamabad');
    expect(p.pendingProductRequests, 7);
  });

  test('falls back to username, then email', () {
    final p = AdminProfileDto.fromJson(const {
      'id': 7,
      'email': 'ops@example.com',
      'role': 'admin',
      'firstName': null,
      'lastName': null,
      'username': null,
    }).toEntity();
    expect(p.fullName, 'ops@example.com');
    expect(p.phone, isNull);
  });
}
