import 'package:go_router/go_router.dart';

import '../../../core/core.dart';
import '../common/admin_common.dart';
import 'presentation/screens/admin_catalogue_detail_screen.dart';
import 'presentation/screens/admin_catalogue_list_screen.dart';

/// Entry points: the Catalogue tab (also Queues → "Catalogue variants" and
/// Scraper results → "Review new variants") → a row (`?id=`).
final List<RouteBase> adminCatalogueRoutes = [
  GoRoute(
    path: AppRoutes.adminCatalogueVariants,
    builder: (_, _) => const AdminCatalogueListScreen(),
  ),
  GoRoute(
    path: AppRoutes.adminCatalogueVariantDetail,
    builder: adminDetailRoute(
      title: 'Variant review',
      notFoundMessage: 'This catalogue variant could not be found.',
      tabIndex: AdminTab.catalogue,
      builder: (id) => AdminCatalogueDetailScreen(variantId: id),
    ),
  ),
];
