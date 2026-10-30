import 'package:equatable/equatable.dart';

import '../../../../core/session/app_role.dart';

class AppStartup extends Equatable {
  const AppStartup({this.role});

  /// Role of the restored session; null means signed out.
  final AppRole? role;

  bool get isSignedIn => role != null;

  @override
  List<Object?> get props => [role];
}
