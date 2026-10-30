import '../entities/location_level.dart';
import '../entities/location_step.dart';

abstract interface class LocationRepository {
  /// Options for [level] under the current parent choices. Missing parents
  /// are filled with a sensible default so any step can open directly.
  Future<LocationStep> getStep(LocationLevel level);

  /// Saves the choice for [level] and clears every level below it. Picking
  /// an area also moves the app's current location to its city.
  Future<void> select(LocationLevel level, String optionId);

  /// Option id best matching the device location at [level].
  Future<String?> detectCurrent(LocationLevel level);

  Future<void> requestAvailabilityUpdates(String phone);
}
