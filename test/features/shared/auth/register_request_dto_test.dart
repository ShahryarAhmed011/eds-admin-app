import 'package:eds_admin_app/features/shared/auth/data/dto/register_request_dto.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  RegisterRequestDto request(String role) => RegisterRequestDto(
    firstName: 'Ali',
    lastName: 'Khan',
    email: 'user@example.com',
    password: 'Abcd-1234',
    role: role,
    phoneCountryCode: '+92',
    phoneNumber: '3001234567',
  );

  test('sends the role as role_id, matching the API body', () {
    expect(request('customer').toJson(), {
      'firstName': 'Ali',
      'lastName': 'Khan',
      'email': 'user@example.com',
      'password': 'Abcd-1234',
      'roleId': 2,
      'phoneCountryCode': '+92',
      'phoneNumber': '3001234567',
    });
    expect(request('rider').toJson()['roleId'], 3);
    expect(request('retailer').toJson()['roleId'], 4);
  });

  test('a role that cannot sign up is rejected', () {
    expect(() => request('admin').toJson(), throwsArgumentError);
  });
}
