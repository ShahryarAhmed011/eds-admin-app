import 'package:flutter/material.dart';

import '../router/app_routes.dart';
import 'eds_nav_item.dart';

/// Bottom navigation configuration per role.
abstract final class RoleNavs {
  static const admin = [
    EdsNavItem(
      label: 'Home',
      icon: Icons.home_outlined,
      selectedIcon: Icons.home,
      route: AppRoutes.adminHome,
    ),
    EdsNavItem(
      label: 'Shops',
      icon: Icons.storefront_outlined,
      selectedIcon: Icons.storefront,
      route: AppRoutes.adminShops,
    ),
    EdsNavItem(
      label: 'Users',
      icon: Icons.person_outline,
      selectedIcon: Icons.person,
      route: AppRoutes.adminUsers,
    ),
    EdsNavItem(
      label: 'Catalogue',
      icon: Icons.grid_view_outlined,
      selectedIcon: Icons.grid_view,
      route: AppRoutes.adminCatalogueVariants,
    ),
    EdsNavItem(
      label: 'More',
      icon: Icons.more_horiz,
      route: AppRoutes.adminMore,
    ),
  ];
}

/// Tab indices, so screens don't hard-code magic numbers.
abstract final class AdminTab {
  static const home = 0, shops = 1, users = 2, catalogue = 3, more = 4;

  /// Review queues (KYC, product requests) open from Home, so they keep
  /// the Home tab selected.
  static const queues = home;
}
