import 'package:equatable/equatable.dart';

/// One choice in a location list (country, province, city, town or area).
class GeoOption extends Equatable {
  const GeoOption({required this.id, required this.name});

  final String id;
  final String name;

  @override
  List<Object?> get props => [id, name];
}

/// Location levels, in drill-down order.
enum GeoLevel {
  country('Country'),
  province('Province'),
  city('City'),
  town('Town'),
  area('Area');

  const GeoLevel(this.label);

  final String label;

  GeoLevel? get next =>
      index + 1 < GeoLevel.values.length ? GeoLevel.values[index + 1] : null;
}

/// What "Complete your profile" edits. Location is a chosen id per level.
class ProfileDetails extends Equatable {
  const ProfileDetails({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    this.phoneVerified = false,
    this.gender,
    this.dateOfBirth,
    this.location = const {},
    this.address = '',
  });

  final String firstName;
  final String lastName;

  /// Read-only here.
  final String email;

  /// "+92 300-1234567", read-only here.
  final String phone;
  final bool phoneVerified;

  /// `male`, `female` or `other`.
  final String? gender;
  final DateTime? dateOfBirth;

  /// Chosen id for each level picked so far.
  final Map<GeoLevel, String> location;

  /// House / street, typed when the town has no areas to pick.
  final String address;

  String get initials => [firstName, lastName]
      .where((part) => part.trim().isNotEmpty)
      .map((part) => part.trim()[0].toUpperCase())
      .join();

  ProfileDetails copyWith({
    String? firstName,
    String? lastName,
    String? gender,
    DateTime? dateOfBirth,
    Map<GeoLevel, String>? location,
    String? address,
  }) => ProfileDetails(
    firstName: firstName ?? this.firstName,
    lastName: lastName ?? this.lastName,
    email: email,
    phone: phone,
    phoneVerified: phoneVerified,
    gender: gender ?? this.gender,
    dateOfBirth: dateOfBirth ?? this.dateOfBirth,
    location: location ?? this.location,
    address: address ?? this.address,
  );

  /// [level] set to [id]; the levels under it are cleared.
  ProfileDetails choose(GeoLevel level, String id) => copyWith(
    location: {
      for (final entry in location.entries)
        if (entry.key.index < level.index) entry.key: entry.value,
      level: id,
    },
  );

  @override
  List<Object?> get props => [
    firstName,
    lastName,
    email,
    phone,
    phoneVerified,
    gender,
    dateOfBirth,
    location,
    address,
  ];
}
