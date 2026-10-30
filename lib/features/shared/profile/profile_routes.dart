import 'package:go_router/go_router.dart';

import '../../../core/core.dart';
import 'presentation/screens/complete_profile_screen.dart';
import 'presentation/screens/profile_screen.dart';

final List<RouteBase> sharedProfileRoutes = [
  GoRoute(path: AppRoutes.profile, builder: (_, _) => const ProfileScreen()),
  GoRoute(
    path: AppRoutes.completeProfile,
    builder: (_, _) => const CompleteProfileScreen(),
  ),
];
