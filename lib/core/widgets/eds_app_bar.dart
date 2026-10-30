import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../theme/theme.dart';

enum EdsAppBarLeading { back, brand, none }

/// White header: back (when there's somewhere to go), the title and, on
/// screens with no other way out, "Log out".
class EdsAppBar extends StatelessWidget implements PreferredSizeWidget {
  const EdsAppBar({
    super.key,
    required this.title,
    this.leading = EdsAppBarLeading.back,
    this.onBack,
    this.onLogout,
  });

  final String title;
  final EdsAppBarLeading leading;
  final VoidCallback? onBack;

  /// Shows "Log out" on the right (screens with no other way out).
  final VoidCallback? onLogout;

  static const height = 60.0;

  @override
  Size get preferredSize => const Size.fromHeight(height);

  @override
  Widget build(BuildContext context) {
    final lead = _buildLeading(context);
    return Material(
      color: AppColors.white,
      child: SafeArea(
        bottom: false,
        child: Container(
          height: height,
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: AppColors.border)),
          ),
          padding: EdgeInsets.only(
            left: lead == null ? AppSpacing.lg : AppSpacing.xs,
            right: AppSpacing.xs,
          ),
          child: Row(
            children: [
              if (lead != null) SizedBox(width: 48, child: lead),
              Expanded(
                child: Text(
                  title,
                  style: AppTextStyles.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (onLogout case final onLogout?)
                TextButton(
                  onPressed: onLogout,
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.crimson,
                  ),
                  child: Text(
                    'Log out',
                    style: AppTextStyles.link.copyWith(
                      color: AppColors.crimson,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget? _buildLeading(BuildContext context) {
    // Tab roots and the first screen after sign in have nothing to pop.
    final canGoBack = onBack != null || GoRouter.of(context).canPop();
    return switch (leading) {
      EdsAppBarLeading.back when !canGoBack => null,
      EdsAppBarLeading.back => IconButton(
        tooltip: 'Back',
        onPressed: onBack ?? () => _defaultBack(context),
        icon: const Icon(Icons.arrow_back, color: AppColors.ink),
      ),
      EdsAppBarLeading.brand => const Icon(
        Icons.shopping_bag_outlined,
        color: AppColors.ink,
      ),
      EdsAppBarLeading.none => null,
    };
  }

  void _defaultBack(BuildContext context) => GoRouter.of(context).pop();
}
