/// One step of the delivery location drill-down.
enum LocationLevel {
  country('Country'),
  province('Province'),
  city('City'),
  town('Town'),
  area('Area'),

  /// The area step after picking an area we don't serve yet.
  notServed('Area');

  const LocationLevel(this.label);

  final String label;

  static const totalSteps = 5;

  /// The levels a user picks, in drill-down order.
  static const pickerLevels = [country, province, city, town, area];

  /// The level whose selection this step edits.
  LocationLevel get selectionLevel => this == notServed ? area : this;

  int get stepNumber => selectionLevel.index + 1;

  /// Next level to choose, or null when this is the last step.
  LocationLevel? get next => switch (this) {
    country => province,
    province => city,
    city => town,
    town => area,
    area || notServed => null,
  };

  /// Levels chosen before this one.
  List<LocationLevel> get ancestors =>
      pickerLevels.take(selectionLevel.index).toList();
}
