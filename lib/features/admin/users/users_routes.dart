import 'package:go_router/go_router.dart';

import '../../../core/core.dart';
import '../common/admin_common.dart';
import 'presentation/screens/admin_user_detail_screen.dart';
import 'presentation/screens/admin_users_list_screen.dart';

/// Entry points: the Users tab (also Queues → "Flagged users") → a row.
final List<RouteBase> adminUsersRoutes = [
  GoRoute(
    path: AppRoutes.adminUsers,
    builder: (_, _) => const AdminUsersListScreen(),
  ),
  GoRoute(
    path: AppRoutes.adminUserDetail,
    builder: adminDetailRoute(
      title: 'User review',
      notFoundMessage: 'This user could not be found.',
      tabIndex: AdminTab.users,
      builder: (id) => AdminUserDetailScreen(userId: id),
    ),
  ),
];
