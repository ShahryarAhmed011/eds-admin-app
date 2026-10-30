import '../../../../../core/core.dart';
import '../../domain/entities/location_option.dart';
import '../dto/geo_item_dto.dart';

extension GeoItemDtoMapper on GeoItemDto {
  LocationOption toEntity() => LocationOption(
    id: id,
    name: name,
    served: isServiceable,
    point: switch ((latitude, longitude)) {
      (final lat?, final lng?) => GeoPoint(lat, lng),
      _ => null,
    },
  );
}
