import 'package:go_router/go_router.dart';

import '../../../core/core.dart';
import '../common/admin_common.dart';
import 'presentation/screens/admin_product_request_detail_screen.dart';
import 'presentation/screens/admin_product_requests_list_screen.dart';

/// Entry points: More → "Product requests" and Queues → "Product requests"
/// → a row (`?id=`).
final List<RouteBase> adminProductRequestsRoutes = [
  GoRoute(
    path: AppRoutes.adminProductRequests,
    builder: (_, _) => const AdminProductRequestsListScreen(),
  ),
  GoRoute(
    path: AppRoutes.adminProductRequestDetail,
    builder: adminDetailRoute(
      title: 'Review request',
      notFoundMessage: 'This product request could not be found.',
      tabIndex: AdminTab.queues,
      builder: (id) => AdminProductRequestDetailScreen(requestId: id),
    ),
  ),
];
