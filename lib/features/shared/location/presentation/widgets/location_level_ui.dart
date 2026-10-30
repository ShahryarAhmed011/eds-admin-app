import '../../domain/entities/location_level.dart';
import '../../domain/entities/location_option.dart';

/// Copy for each [LocationLevel].
extension LocationLevelUi on LocationLevel {
  String get sheetTitle => this == LocationLevel.notServed
      ? 'Not served yet'
      : 'Choose ${label.toLowerCase()}';

  String get searchHint => 'Search ${label.toLowerCase()}';

  String get continueLabel => switch (next) {
    final next? => 'Continue to ${next.label.toLowerCase()}',
    null => 'Confirm location',
  };
}

extension LocationOptionUi on LocationOption {
  /// "G-11/3 · Served", "Taxila · Not served yet" or just the name.
  String get displayName => switch (served) {
    true => '$name · Served',
    false => '$name · Not served yet',
    null => name,
  };
}
