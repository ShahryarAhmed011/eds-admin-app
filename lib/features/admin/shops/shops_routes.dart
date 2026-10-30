import 'package:go_router/go_router.dart';

import '../../../core/core.dart';
import '../common/admin_common.dart';
import 'presentation/screens/admin_shop_detail_screen.dart';
import 'presentation/screens/admin_shops_list_screen.dart';

/// Entry points: the Shops tab (also Queues → "Shops ready for activation")
/// → a row, or User detail → linked shop.
final List<RouteBase> adminShopsRoutes = [
  GoRoute(
    path: AppRoutes.adminShops,
    builder: (_, _) => const AdminShopsListScreen(),
  ),
  GoRoute(
    path: AppRoutes.adminShopDetail,
    builder: adminDetailRoute(
      title: 'Shop review',
      notFoundMessage: 'This shop could not be found.',
      tabIndex: AdminTab.shops,
      builder: (id) => AdminShopDetailScreen(shopId: id),
    ),
  ),
];
