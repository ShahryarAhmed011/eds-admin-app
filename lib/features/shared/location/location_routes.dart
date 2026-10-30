import 'package:go_router/go_router.dart';

import '../../../core/core.dart';
import 'presentation/screens/location_screen.dart';

/// One route hosts the whole drill-down (country → province → city → town
/// → area, plus "not served" after an unserved pick).
final List<RouteBase> sharedLocationRoutes = [
  GoRoute(
    path: AppRoutes.locationCountry,
    builder: (_, _) => const LocationScreen(),
  ),
];
