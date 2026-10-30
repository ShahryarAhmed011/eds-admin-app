import 'package:go_router/go_router.dart';

import '../../../core/core.dart';
import 'presentation/screens/admin_home_screen.dart';
import 'presentation/screens/admin_queues_screen.dart';

/// Admin home (`AppRole.admin.homeRoute`) and the review queues.
final List<RouteBase> adminQueuesRoutes = [
  GoRoute(
    path: AppRoutes.adminHome,
    builder: (_, _) => const AdminHomeScreen(),
  ),
  GoRoute(
    path: AppRoutes.adminQueues,
    builder: (_, _) => const AdminQueuesScreen(),
  ),
];
