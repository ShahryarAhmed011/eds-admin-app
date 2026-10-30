import 'package:flutter/widgets.dart';

class EdsNavItem {
  const EdsNavItem({
    required this.label,
    required this.icon,
    required this.route,
    this.selectedIcon,
  });

  final String label;

  /// Outlined glyph for the tab at rest.
  final IconData icon;

  /// Filled glyph for the active tab; falls back to [icon].
  final IconData? selectedIcon;
  final String route;
}
