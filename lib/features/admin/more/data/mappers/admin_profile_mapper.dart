import '../../../../../core/core.dart';
import '../../domain/entities/admin_profile.dart';
import '../dto/admin_profile_dto.dart';

extension AdminProfileDtoMapper on AdminProfileDto {
  AdminProfile toEntity({int? pendingProductRequests}) {
    final name = [
      firstName,
      lastName,
    ].whereType<String>().where((s) => s.trim().isNotEmpty).join(' ');
    return AdminProfile(
      fullName: name.isNotEmpty
          ? name
          : (username?.isNotEmpty ?? false)
          ? username!
          : email,
      email: email,
      role: AppRole.fromApi(role),
      city: city,
      phone: formatPhone(phoneCountryCode, phoneNumber),
      pendingProductRequests: pendingProductRequests,
    );
  }
}

/// "+92" + "3009876543" → "+92 300 9876543".
String? formatPhone(String? code, String? number) {
  final digits = number?.replaceAll(RegExp(r'[^0-9]'), '') ?? '';
  if (digits.isEmpty) return null;
  final local = digits.length > 3
      ? '${digits.substring(0, 3)} ${digits.substring(3)}'
      : digits;
  return (code == null || code.isEmpty) ? local : '$code $local';
}
