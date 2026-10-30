import '../../../../../core/core.dart';

/// Area as returned by `GET /geo/towns/{id}/areas` and
/// `PATCH /admin/geo/areas/{id}/serviceability`. The impact counts are not
/// in the API yet and are only filled by the dummy source.
class ServiceAreaDto {
  const ServiceAreaDto({
    required this.id,
    required this.name,
    required this.isServiceable,
    this.townId,
    this.postalCode,
    this.shopCount,
    this.savedAddressCount,
    this.waitlistAvailable = false,
  });

  factory ServiceAreaDto.fromJson(Json json) => ServiceAreaDto(
    id: json.id(),
    townId: json.str('townId'),
    name: json.strOr('name'),
    postalCode: json.str('postalCode'),
    isServiceable: json.boolean('isServiceable'),
    shopCount: json.integer('shopCount'),
    savedAddressCount: json.integer('savedAddressCount'),
    waitlistAvailable: json.boolean('waitlistAvailable'),
  );

  final String id;
  final String? townId;
  final String name;
  final String? postalCode;
  final bool isServiceable;
  final int? shopCount;
  final int? savedAddressCount;
  final bool waitlistAvailable;
}

/// A city/town pair (from `/geo/cities` and `/geo/cities/{id}/towns`) with
/// the town's areas.
class ServiceAreaScopeDto {
  const ServiceAreaScopeDto({
    required this.cityName,
    required this.townName,
    required this.areas,
    this.countryName,
    this.regionName,
  });

  factory ServiceAreaScopeDto.fromJson(Json json) => ServiceAreaScopeDto(
    countryName: json.obj('country')?.str('name'),
    regionName: json.obj('province')?.str('name'),
    cityName: json.obj('city')?.strOr('name') ?? '',
    townName: json.obj('town')?.strOr('name') ?? '',
    areas: [
      for (final item in json.objList('areas')) ServiceAreaDto.fromJson(item),
    ],
  );

  final String? countryName;
  final String? regionName;
  final String cityName;
  final String townName;
  final List<ServiceAreaDto> areas;
}
