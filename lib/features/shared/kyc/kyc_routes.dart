import 'package:go_router/go_router.dart';

import '../../../core/core.dart';
import 'presentation/screens/verify_identity_screen.dart';

final List<RouteBase> sharedKycRoutes = [
  GoRoute(
    path: AppRoutes.verifyIdentity,
    builder: (_, _) => const VerifyIdentityScreen(),
  ),
];
