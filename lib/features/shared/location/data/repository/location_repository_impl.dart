import '../../../../../core/core.dart';
import '../../domain/entities/location_level.dart';
import '../../domain/entities/location_option.dart';
import '../../domain/entities/location_step.dart';
import '../../domain/repository/location_repository.dart';
import '../data_sources/location_data_source.dart';
import '../dto/geo_item_dto.dart';
import '../mappers/location_mappers.dart';

/// Keeps the picker's choices in memory for the session and walks the
/// `/geo` cascade from them.
class LocationRepositoryImpl implements LocationRepository {
  LocationRepositoryImpl(this._dataSource, this._currentLocation);

  final LocationDataSource _dataSource;
  final CurrentLocation _currentLocation;

  /// A level that is absent has never been chosen (gets a default); a
  /// level present with null was cleared by a parent change.
  final Map<LocationLevel, LocationOption?> _selected = {};
  final Map<String, List<LocationOption>> _cache = {};

  @override
  Future<LocationStep> getStep(LocationLevel level) async {
    final target = level.selectionLevel;
    for (final ancestor in target.ancestors) {
      if (_selected[ancestor] == null) {
        _selected[ancestor] = _defaultPick(await _optionsFor(ancestor));
      }
    }
    final options = await _optionsFor(target);
    if (!_selected.containsKey(target)) {
      _selected[target] = _defaultPick(options);
    }
    final selection = {
      for (final l in LocationLevel.pickerLevels) l: ?_selected[l]?.name,
    };

    if (level == LocationLevel.notServed) {
      final current = _selected[LocationLevel.area];
      final unserved = current != null && current.isUnserved
          ? current
          : options.where((o) => o.isUnserved).firstOrNull;
      return LocationStep(
        level: level,
        options: [?unserved, ...options.where((o) => !o.isUnserved)],
        selectedId: unserved?.id,
        selection: selection,
        unservedAreaName: unserved?.name,
        notifyPhone: await _dataSource.fetchContactPhone(),
      );
    }

    return LocationStep(
      level: level,
      options: options,
      selectedId: _selected[target]?.id,
      selection: selection,
    );
  }

  @override
  Future<void> select(LocationLevel level, String optionId) async {
    final options = await _optionsFor(level);
    final option = options.firstWhere((o) => o.id == optionId);
    if (_selected[level]?.id != optionId) {
      for (final child in LocationLevel.pickerLevels.skip(level.index + 1)) {
        _selected[child] = null;
      }
    }
    _selected[level] = option;
    if (level == LocationLevel.area) {
      // API areas carry no coordinates; the city's centre is the fallback.
      final point = option.point ?? _selected[LocationLevel.city]?.point;
      if (point != null) _currentLocation.set(point);
    }
  }

  @override
  Future<String?> detectCurrent(LocationLevel level) async {
    final options = await _optionsFor(level);
    if (level == LocationLevel.city) {
      final here = await _currentLocation.get();
      LocationOption? nearest;
      double? best;
      for (final option in options) {
        final point = option.point;
        if (point == null) continue;
        final dLat = point.latitude - here.latitude;
        final dLng = point.longitude - here.longitude;
        final distance = dLat * dLat + dLng * dLng;
        if (best == null || distance < best) {
          best = distance;
          nearest = option;
        }
      }
      if (nearest != null) return nearest.id;
    }
    return _defaultPick(options)?.id;
  }

  @override
  Future<void> requestAvailabilityUpdates(String phone) =>
      _dataSource.requestAvailabilityUpdates(phone);

  /// First served option, else the first option.
  LocationOption? _defaultPick(List<LocationOption> options) =>
      options.where((o) => o.served != false).firstOrNull ??
      options.firstOrNull;

  Future<List<LocationOption>> _optionsFor(LocationLevel level) async {
    final parent = level.index == 0
        ? null
        : _selected[LocationLevel.pickerLevels[level.index - 1]]?.id;
    final key = '${level.name}:$parent';
    if (_cache[key] case final cached?) return cached;
    final List<GeoItemDto> items = switch (level) {
      LocationLevel.country => await _dataSource.fetchCountries(),
      LocationLevel.province => await _dataSource.fetchProvinces(parent!),
      LocationLevel.city => await _dataSource.fetchCities(parent!),
      LocationLevel.town => await _dataSource.fetchTowns(parent!),
      LocationLevel.area ||
      LocationLevel.notServed => await _dataSource.fetchAreas(parent!),
    };
    return _cache[key] = [for (final item in items) item.toEntity()];
  }
}
