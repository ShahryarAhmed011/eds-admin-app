import 'package:flutter/material.dart';

import '../theme/theme.dart';

/// White rounded card with a hairline (Gray @ 20%) border.
class EdsCard extends StatelessWidget {
  const EdsCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppSpacing.lg),
    this.onTap,
    this.color = AppColors.white,
    this.borderColor,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final Color color;

  /// Defaults to [AppColors.border].
  final Color? borderColor;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color,
      shape: RoundedRectangleBorder(
        borderRadius: AppRadius.mdAll,
        side: BorderSide(color: borderColor ?? AppColors.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(padding: padding, child: child),
      ),
    );
  }
}

/// Card that stacks [children] with optional dividers between them.
/// Use for grouped lists (settings menus, checklists, search results).
class EdsGroupCard extends StatelessWidget {
  const EdsGroupCard({
    super.key,
    required this.children,
    this.header,
    this.showDividers = false,
  });

  final List<Widget> children;
  final Widget? header;
  final bool showDividers;

  @override
  Widget build(BuildContext context) {
    return EdsCard(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (header != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.md,
                AppSpacing.lg,
                AppSpacing.xs,
              ),
              child: header,
            ),
          for (var i = 0; i < children.length; i++) ...[
            if (showDividers && i > 0)
              const Divider(indent: AppSpacing.lg, endIndent: AppSpacing.lg),
            children[i],
          ],
        ],
      ),
    );
  }
}
