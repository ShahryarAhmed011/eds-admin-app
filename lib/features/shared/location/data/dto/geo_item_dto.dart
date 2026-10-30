import '../../../../../core/core.dart';

/// One item of any `/geo/...` cascade list (country, province, city, town
/// or area). Fields a level doesn't send stay null.
class GeoItemDto {
  const GeoItemDto({
    required this.id,
    required this.name,
    this.isServiceable,
    this.latitude,
    this.longitude,
    this.postalCode,
  });

  factory GeoItemDto.fromJson(Json json) => GeoItemDto(
    id: json.id(),
    name: json.strOr('name'),
    isServiceable: json.containsKey('isServiceable')
        ? json.boolean('isServiceable')
        : null,
    latitude: json.decimal('latitude'),
    longitude: json.decimal('longitude'),
    postalCode: json.str('postalCode'),
  );

  final String id;
  final String name;
  final bool? isServiceable;
  final double? latitude;
  final double? longitude;
  final String? postalCode;
}
