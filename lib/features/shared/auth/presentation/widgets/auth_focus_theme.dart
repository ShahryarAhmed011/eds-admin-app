import 'package:flutter/material.dart';

import '../../../../../core/core.dart';

/// Gives the auth fields under it Crimson icons, a Crimson border while
/// focused, and a Crimson border and message on an error (the app defaults
/// are Gray icons and Ink borders and errors).
class AuthFocusTheme extends StatelessWidget {
  const AuthFocusTheme({super.key, required this.child});

  final Widget child;

  static const _highlight = BorderSide(color: AppColors.crimson, width: 1.5);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final decoration = theme.inputDecorationTheme;
    return Theme(
      data: theme.copyWith(
        inputDecorationTheme: decoration.copyWith(
          prefixIconColor: AppColors.crimson,
          suffixIconColor: AppColors.crimson,
          focusedBorder: decoration.focusedBorder?.copyWith(
            borderSide: _highlight,
          ),
          errorBorder: decoration.errorBorder?.copyWith(borderSide: _highlight),
          focusedErrorBorder: decoration.focusedErrorBorder?.copyWith(
            borderSide: _highlight,
          ),
          errorStyle: AppTextStyles.caption.copyWith(color: AppColors.crimson),
        ),
      ),
      child: child,
    );
  }
}
