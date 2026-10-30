import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';

import 'admin/areas/areas.dart';
import 'admin/audit_log/audit_log.dart';
import 'admin/catalogue/catalogue.dart' as admin_catalogue;
import 'admin/kyc/kyc.dart';
import 'admin/more/more.dart';
import 'admin/product_requests/product_requests.dart' as admin_requests;
import 'admin/queues/queues.dart';
import 'admin/scraper/scraper.dart';
import 'admin/shops/shops.dart';
import 'admin/users/users.dart';
import 'shared/auth/auth.dart';
import 'shared/kyc/kyc.dart';
import 'shared/location/location.dart';
import 'shared/profile/profile.dart';

/// Single place where every feature module plugs in its DI and routes.
abstract final class FeatureRegistry {
  static void registerDependencies(GetIt sl) {
    // Shared
    registerSharedAuth(sl);
    registerSharedLocation(sl);
    registerSharedProfile(sl);
    registerSharedKyc(sl);
    // Admin
    registerAdminQueues(sl);
    registerAdminKyc(sl);
    registerAdminUsers(sl);
    registerAdminShops(sl);
    registerAdminMore(sl);
    admin_catalogue.registerAdminCatalogue(sl);
    admin_requests.registerAdminProductRequests(sl);
    registerAdminScraper(sl);
    registerAdminAreas(sl);
    registerAdminAuditLog(sl);
  }

  static final List<RouteBase> routes = [
    ...sharedAuthRoutes,
    ...sharedLocationRoutes,
    ...sharedProfileRoutes,
    ...sharedKycRoutes,
    ...adminQueuesRoutes,
    ...adminKycRoutes,
    ...adminUsersRoutes,
    ...adminShopsRoutes,
    ...adminMoreRoutes,
    ...admin_catalogue.adminCatalogueRoutes,
    ...admin_requests.adminProductRequestsRoutes,
    ...adminScraperRoutes,
    ...adminAreasRoutes,
    ...adminAuditLogRoutes,
  ];
}
