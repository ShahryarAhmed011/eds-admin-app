import 'package:equatable/equatable.dart';

class GeoPoint extends Equatable {
  const GeoPoint(this.latitude, this.longitude);

  final double latitude;
  final double longitude;

  Map<String, dynamic> toQuery() => {'lat': latitude, 'lng': longitude};

  @override
  List<Object?> get props => [latitude, longitude];
}

/// Source of the customer's delivery coordinates for discovery calls.
abstract interface class CurrentLocation {
  Future<GeoPoint> get();
  void set(GeoPoint point);
}

/// Holds the last chosen point in memory. Defaults to G-11/3, Islamabad
/// (the Figma delivery address) until GPS / saved addresses are wired.
class InMemoryCurrentLocation implements CurrentLocation {
  GeoPoint _point = const GeoPoint(33.6687, 72.9974);

  @override
  Future<GeoPoint> get() async => _point;

  @override
  void set(GeoPoint point) => _point = point;
}
