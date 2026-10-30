import 'package:equatable/equatable.dart';

class ServiceArea extends Equatable {
  const ServiceArea({
    required this.id,
    required this.name,
    required this.isServiceable,
    this.postalCode,
    this.shopCount,
    this.savedAddressCount,
    this.waitlistAvailable = false,
  });

  final String id;

  /// Area name, e.g. "G-11/3".
  final String name;
  final bool isServiceable;
  final String? postalCode;

  /// Impact counts. Not provided by the geo API yet.
  final int? shopCount;
  final int? savedAddressCount;
  final bool waitlistAvailable;

  ServiceArea copyWith({bool? isServiceable}) => ServiceArea(
    id: id,
    name: name,
    isServiceable: isServiceable ?? this.isServiceable,
    postalCode: postalCode,
    shopCount: shopCount,
    savedAddressCount: savedAddressCount,
    waitlistAvailable: waitlistAvailable,
  );

  @override
  List<Object?> get props => [
    id,
    name,
    isServiceable,
    postalCode,
    shopCount,
    savedAddressCount,
    waitlistAvailable,
  ];
}

/// The location an admin is managing (city → town) and its areas.
class ServiceAreaScope extends Equatable {
  const ServiceAreaScope({
    required this.city,
    required this.town,
    required this.areas,
    this.country,
    this.region,
  });

  final String? country;
  final String? region;
  final String city;

  /// Town / sector whose areas are listed ("G-11").
  final String town;
  final List<ServiceArea> areas;

  String get label => [?country, ?region, city, town].join(' · ');

  int get servedCount => areas.where((a) => a.isServiceable).length;

  ServiceAreaScope copyWithArea(ServiceArea area) => ServiceAreaScope(
    country: country,
    region: region,
    city: city,
    town: town,
    areas: [for (final a in areas) a.id == area.id ? area : a],
  );

  @override
  List<Object?> get props => [country, region, city, town, areas];
}
