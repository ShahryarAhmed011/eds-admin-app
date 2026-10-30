import 'package:go_router/go_router.dart';

import '../../../core/core.dart';
import 'presentation/screens/admin_more_screen.dart';

/// The More tab.
final List<RouteBase> adminMoreRoutes = [
  GoRoute(
    path: AppRoutes.adminMore,
    builder: (_, _) => const AdminMoreScreen(),
  ),
];
