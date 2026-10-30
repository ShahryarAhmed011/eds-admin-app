import 'package:flutter/material.dart';

import '../../../../../core/core.dart';

/// Product header card: letter avatar, name, meta line, highlighted price or
/// status line and a badge. Shared by catalogue variant review and product
/// request review.
class AdminProductSummaryCard extends StatelessWidget {
  const AdminProductSummaryCard({
    super.key,
    required this.name,
    required this.subtitle,
    required this.highlight,
    this.badge,
    this.badgeTone = EdsTone.warning,
  });

  final String name;
  final String subtitle;

  /// Orange line under the subtitle ("Market median Rs 280").
  final String highlight;
  final String? badge;
  final EdsTone badgeTone;

  @override
  Widget build(BuildContext context) {
    return EdsCard(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: EdsListTile(
        leading: EdsAvatar(text: name),
        title: name,
        titleStyle: AppTextStyles.itemTitleLarge,
        subtitle: subtitle,
        extra: Text(highlight, style: AppTextStyles.price),
        trailing: badge == null ? null : EdsBadge(badge!, tone: badgeTone),
      ),
    );
  }
}
