import 'package:eds_admin_app/features/admin/users/data/dto/admin_user_dto.dart';
import 'package:eds_admin_app/features/admin/users/data/mappers/admin_user_mapper.dart';
import 'package:eds_admin_app/features/admin/users/domain/entities/admin_user.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // GET /admin/users item, field names from docs/api/curl-reference.md.
  const row = {
    'id': 88,
    'fullName': 'Bilal Hassan',
    'email': 'bilal@example.com',
    'role': 'retailer',
    'status': 'suspended',
    'onboardingStatus': 'live',
    'createdAt': '2026-09-02T05:15:00Z',
  };

  test('maps an API user', () {
    final u = AdminUserDto.fromJson(row).toEntity();
    expect(u.id, '88');
    expect(u.reference, 'USR-88');
    expect(u.name, 'Bilal Hassan');
    expect(u.role, AdminUserRole.retailer);
    expect(u.status, AdminUserStatus.suspended);
    expect(u.createdAt, DateTime.utc(2026, 9, 2, 5, 15));
    expect(u.phone, isNull);
    expect(u.shop, isNull);
  });

  test('unknown status keeps the raw value; empty name falls back', () {
    final u = AdminUserDto.fromJson({
      ...row,
      'fullName': '',
      'status': 'shadow_banned',
      'role': 'auditor',
    }).toEntity();
    expect(u.status, AdminUserStatus.unknown);
    expect(u.rawStatus, 'shadow_banned');
    expect(u.role, AdminUserRole.other);
    expect(u.name, 'bilal@example.com');
  });

  test('actions map to API status strings', () {
    expect(adminUserActionToApi(AdminUserAccessAction.suspend), 'suspended');
    expect(adminUserActionToApi(AdminUserAccessAction.restore), 'active');
    expect(adminUserActionToApi(AdminUserAccessAction.keepActive), 'active');
  });

  test('a bare PATCH response keeps Figma-only extras', () {
    final before = AdminUserDto.fromJson({
      ...row,
      'phone': '+92 302 4567890',
    }).toEntity();
    final after = AdminUserDto.fromJson({
      ...row,
      'status': 'active',
    }).toEntity().mergeFrom(before);
    expect(after.status, AdminUserStatus.active);
    expect(after.phone, '+92 302 4567890');
  });
}
