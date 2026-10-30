import '../../domain/entities/service_area.dart';
import '../dto/service_area_dto.dart';

extension ServiceAreaDtoMapper on ServiceAreaDto {
  ServiceArea toEntity() => ServiceArea(
    id: id,
    name: name,
    isServiceable: isServiceable,
    postalCode: postalCode,
    shopCount: shopCount,
    savedAddressCount: savedAddressCount,
    waitlistAvailable: waitlistAvailable,
  );
}

extension ServiceAreaScopeDtoMapper on ServiceAreaScopeDto {
  ServiceAreaScope toEntity() => ServiceAreaScope(
    country: countryName,
    region: regionName,
    city: cityName,
    town: townName,
    areas: [for (final a in areas) a.toEntity()],
  );
}
