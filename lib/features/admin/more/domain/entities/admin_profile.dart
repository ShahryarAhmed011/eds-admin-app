import 'package:equatable/equatable.dart';

import '../../../../../core/core.dart';

class AdminProfile extends Equatable {
  const AdminProfile({
    required this.fullName,
    required this.email,
    required this.role,
    this.city,
    this.phone,
    this.pendingProductRequests,
  });

  final String fullName;
  final String email;
  final AppRole role;
  final String? city;
  final String? phone;

  /// Null when the count could not be loaded.
  final int? pendingProductRequests;

  @override
  List<Object?> get props => [
    fullName,
    email,
    role,
    city,
    phone,
    pendingProductRequests,
  ];
}
