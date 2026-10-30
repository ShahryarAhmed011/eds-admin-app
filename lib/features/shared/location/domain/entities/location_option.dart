import 'package:equatable/equatable.dart';

import '../../../../../core/core.dart';

/// A selectable country, province, city, town or area.
class LocationOption extends Equatable {
  const LocationOption({
    required this.id,
    required this.name,
    this.served,
    this.point,
  });

  final String id;
  final String name;

  /// `is_serviceable`. Null for levels that don't report it (countries,
  /// provinces).
  final bool? served;

  /// Centre point; only cities carry one.
  final GeoPoint? point;

  bool get isUnserved => served == false;

  @override
  List<Object?> get props => [id, name, served, point];
}
