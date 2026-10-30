import '../../domain/entities/service_area.dart';

extension ServiceAreaLabels on ServiceArea {
  String get title => '$name · ${isServiceable ? 'Serviceable' : 'Not served'}';

  /// "14 shops · 83 saved addresses", or null when counts are unknown.
  String? get impactLabel {
    final parts = [
      if (shopCount != null) '$shopCount shops',
      if (savedAddressCount != null) '$savedAddressCount saved addresses',
    ];
    return parts.isEmpty ? null : parts.join(' · ');
  }

  String? get subtitle {
    if (isServiceable) {
      return impactLabel ??
          (postalCode == null ? null : 'Postal code $postalCode');
    }
    final parts = [
      if (shopCount != null) '$shopCount live shops',
      if (waitlistAvailable) 'Waitlist available',
    ];
    return parts.isEmpty ? null : parts.join(' · ');
  }
}
