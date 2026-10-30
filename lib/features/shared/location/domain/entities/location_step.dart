import 'package:equatable/equatable.dart';

import 'location_level.dart';
import 'location_option.dart';

/// Everything needed to render one step of the location picker.
class LocationStep extends Equatable {
  const LocationStep({
    required this.level,
    required this.options,
    required this.selectedId,
    required this.selection,
    this.unservedAreaName,
    this.notifyPhone,
  });

  final LocationLevel level;
  final List<LocationOption> options;
  final String? selectedId;

  /// Names of the current choice at each picker level.
  final Map<LocationLevel, String> selection;

  /// Not-served step only.
  final String? unservedAreaName;
  final String? notifyPhone;

  LocationOption? get selectedOption {
    for (final option in options) {
      if (option.id == selectedId) return option;
    }
    return null;
  }

  /// "Pakistan → Islamabad Capital Territory" for the levels above this one.
  /// The first step shows the whole drill-down instead.
  String get breadcrumb => level == LocationLevel.country
      ? LocationLevel.pickerLevels.map((l) => l.label).join(' → ')
      : [
          for (final ancestor in level.ancestors) ?selection[ancestor],
        ].join(' → ');

  LocationStep copyWith({String? selectedId}) => LocationStep(
    level: level,
    options: options,
    selectedId: selectedId ?? this.selectedId,
    selection: selection,
    unservedAreaName: unservedAreaName,
    notifyPhone: notifyPhone,
  );

  @override
  List<Object?> get props => [
    level,
    options,
    selectedId,
    selection,
    unservedAreaName,
    notifyPhone,
  ];
}
