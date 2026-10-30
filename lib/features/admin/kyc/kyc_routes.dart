import 'package:go_router/go_router.dart';

import '../../../core/core.dart';
import '../common/admin_common.dart';
import 'presentation/screens/kyc_applicant_detail_screen.dart';
import 'presentation/screens/kyc_review_list_screen.dart';

/// Entry points: Queues → "KYC reviews" → a row (`?id=`).
final List<RouteBase> adminKycRoutes = [
  GoRoute(
    path: AppRoutes.adminKycReviewList,
    builder: (_, _) => const KycReviewListScreen(),
  ),
  GoRoute(
    path: AppRoutes.adminKycApplicantDetail,
    builder: adminDetailRoute(
      title: 'Review identity',
      notFoundMessage: 'This identity review could not be found.',
      tabIndex: AdminTab.queues,
      builder: (id) => KycApplicantDetailScreen(applicationId: id),
    ),
  ),
];
