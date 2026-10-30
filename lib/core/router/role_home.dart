import '../session/app_role.dart';
import 'app_routes.dart';

/// Landing route and route prefix for each role.
extension RoleRoutes on AppRole {
  String get homeRoute => switch (this) {
    AppRole.customer => AppRoutes.customerHome,
    AppRole.retailer => AppRoutes.retailerHome,
    AppRole.rider => AppRoutes.riderHome,
    AppRole.admin => AppRoutes.adminHome,
  };

  /// Every route owned by this role starts with this prefix.
  String get routePrefix => '/$apiValue/';
}
