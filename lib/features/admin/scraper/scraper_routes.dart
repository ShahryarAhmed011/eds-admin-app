import 'package:go_router/go_router.dart';

import '../../../core/core.dart';
import 'presentation/screens/admin_scraper_screen.dart';

/// Entry point: More → Catalogue scraper.
final List<RouteBase> adminScraperRoutes = [
  GoRoute(
    path: AppRoutes.adminScraperDashboard,
    builder: (_, _) => const AdminScraperScreen(),
  ),
];
