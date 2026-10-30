import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/core.dart';
import '../bloc/auth_bloc.dart';

/// Reacts to [AuthBloc]'s one-shot outcomes for sign in and sign up:
/// a session goes home by role, a sent code opens the OTP screen.
class AuthNavigationListener extends StatelessWidget {
  const AuthNavigationListener({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listenWhen: (_, current) =>
          current is AuthReady &&
          (current.signedIn != null || current.needsVerification),
      listener: (context, state) {
        final ready = state as AuthReady;
        if (ready.signedIn case final user?) {
          // The router guard already redirects once tokens are stored; `go`
          // here is a no-op safety net and resets the stack either way.
          context.go(user.role.homeRoute);
        } else {
          context.push(AppRoutes.otpVerification);
        }
      },
      child: child,
    );
  }
}
