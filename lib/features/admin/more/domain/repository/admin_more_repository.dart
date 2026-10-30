import '../entities/admin_profile.dart';

abstract interface class AdminMoreRepository {
  Future<AdminProfile> getProfile();
}
