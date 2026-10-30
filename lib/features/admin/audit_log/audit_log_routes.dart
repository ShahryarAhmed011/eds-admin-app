import 'package:go_router/go_router.dart';

import '../../../core/core.dart';
import 'presentation/screens/admin_audit_log_screen.dart';

/// Entry point: More → "Audit log".
final List<RouteBase> adminAuditLogRoutes = [
  GoRoute(
    path: AppRoutes.adminAuditLog,
    builder: (_, _) => const AdminAuditLogScreen(),
  ),
];
