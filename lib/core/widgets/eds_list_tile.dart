import 'package:flutter/material.dart';

import '../theme/theme.dart';

/// Row with optional leading avatar, title/subtitle and trailing widget.
/// The building block for nearly every list in the app.
class EdsListTile extends StatelessWidget {
  const EdsListTile({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    this.trailing,
    this.extra,
    this.onTap,
    this.showChevron = false,
    this.padding = const EdgeInsets.symmetric(
      horizontal: AppSpacing.lg,
      vertical: AppSpacing.md,
    ),
    this.titleStyle,
  });

  final String title;
  final String? subtitle;
  final Widget? leading;

  /// Badge, count, icon or switch. Shown before the chevron if both are set.
  final Widget? trailing;

  /// Extra line below the subtitle, e.g. a price.
  final Widget? extra;
  final VoidCallback? onTap;
  final bool showChevron;
  final EdgeInsetsGeometry padding;
  final TextStyle? titleStyle;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: padding,
        child: Row(
          children: [
            if (leading != null) ...[leading!, AppSpacing.gapMd],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: titleStyle ?? AppTextStyles.itemTitle),
                  if (subtitle != null) ...[
                    const SizedBox(height: AppSpacing.xxs),
                    Text(subtitle!, style: AppTextStyles.bodySecondary),
                  ],
                  if (extra != null) ...[
                    const SizedBox(height: AppSpacing.xxs),
                    extra!,
                  ],
                ],
              ),
            ),
            if (trailing != null) ...[AppSpacing.gapSm, trailing!],
            if (showChevron) ...[
              AppSpacing.gapSm,
              const Icon(Icons.chevron_right, color: AppColors.ink),
            ],
          ],
        ),
      ),
    );
  }
}
