import 'package:flutter/material.dart';

import '../theme/theme.dart';

/// Heading with optional subtitle and trailing widget ("3 flagged accounts").
class EdsSectionHeader extends StatelessWidget {
  const EdsSectionHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.trailing,
    this.eyebrow = false,
  });

  final String title;
  final String? subtitle;
  final Widget? trailing;

  /// Render as a small uppercase green label ("HOW WILL YOU USE EDOORSTEP?").
  final bool eyebrow;

  @override
  Widget build(BuildContext context) {
    final titleWidget = Text(
      eyebrow ? title.toUpperCase() : title,
      style: eyebrow
          ? AppTextStyles.eyebrow.copyWith(fontSize: 12)
          : AppTextStyles.sectionTitle,
    );
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              titleWidget,
              if (subtitle != null) ...[
                const SizedBox(height: AppSpacing.xxs),
                Text(subtitle!, style: AppTextStyles.bodySecondary),
              ],
            ],
          ),
        ),
        ?trailing,
      ],
    );
  }
}
