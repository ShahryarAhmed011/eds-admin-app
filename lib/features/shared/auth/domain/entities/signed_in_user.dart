import 'package:equatable/equatable.dart';

import '../../../../../core/core.dart';

/// Result of a successful login or OTP verification. Where to go next is
/// `role.homeRoute`; the router guard redirects there once tokens are saved.
class SignedInUser extends Equatable {
  const SignedInUser({required this.role});

  final AppRole role;

  @override
  List<Object?> get props => [role];
}
