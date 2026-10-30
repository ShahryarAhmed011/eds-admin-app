import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/core.dart';
import '../../../../core/di/injection.dart';
import '../domain/usecase/logout_use_case.dart';

/// Signs out (best effort on the server, always locally) and opens log in.
/// For screens with no other way out, e.g. onboarding steps.
Future<void> signOutToLogIn(BuildContext context) async {
  await sl<LogoutUseCase>()(const NoParams());
  if (context.mounted) context.go(AppRoutes.signIn);
}
