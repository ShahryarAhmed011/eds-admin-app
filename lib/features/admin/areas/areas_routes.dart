import 'package:go_router/go_router.dart';

import '../../../core/core.dart';
import 'presentation/screens/admin_serviceable_areas_screen.dart';

/// Entry point: More → "Serviceable areas".
final List<RouteBase> adminAreasRoutes = [
  GoRoute(
    path: AppRoutes.adminServiceableAreas,
    builder: (_, _) => const AdminServiceableAreasScreen(),
  ),
];
