import '../../../../../core/core.dart';
import '../dto/admin_profile_dto.dart';
import 'admin_more_data_source.dart';

/// Figma data in the `GET /profile` shape.
class AdminMoreDummyDataSource implements AdminMoreDataSource {
  @override
  Future<AdminProfileDto> fetchProfile() async {
    await dummyDelay();
    return AdminProfileDto.fromJson(const {
      'id': 7,
      'email': 'nadia.ahmed@edoorstep.com',
      'active': true,
      'role': 'admin',
      'firstName': 'Nadia',
      'lastName': 'Ahmed',
      'username': 'nadia.ops',
      'phoneCountryCode': '+92',
      'phoneNumber': '3009876543',
      'city': 'Islamabad',
      'area': null,
    });
  }

  @override
  Future<int> fetchPendingProductRequestCount() async {
    await dummyDelay();
    return 7;
  }
}
