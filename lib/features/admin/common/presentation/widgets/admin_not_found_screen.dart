import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/core.dart';

/// Shown by an admin detail route opened without a usable `?id=`.
class AdminNotFoundScreen extends StatelessWidget {
  const AdminNotFoundScreen({
    super.key,
    required this.title,
    required this.message,
    required this.tabIndex,
  });

  final String title;
  final String message;

  /// Highlighted admin tab ([AdminTab]).
  final int tabIndex;

  @override
  Widget build(BuildContext context) {
    return EdsScaffold(
      title: title,
      bottomNav: EdsBottomNav(items: RoleNavs.admin, currentIndex: tabIndex),
      body: EdsErrorView(message: message),
    );
  }
}

/// Builds an admin detail screen from the route's `?id=` query parameter,
/// or an [AdminNotFoundScreen] when the id is missing or blank.
GoRouterWidgetBuilder adminDetailRoute({
  required Widget Function(String id) builder,
  required String title,
  required String notFoundMessage,
  required int tabIndex,
}) {
  return (context, state) {
    final id = state.uri.queryParameters['id']?.trim() ?? '';
    return id.isEmpty
        ? AdminNotFoundScreen(
            title: title,
            message: notFoundMessage,
            tabIndex: tabIndex,
          )
        : builder(id);
  };
}
