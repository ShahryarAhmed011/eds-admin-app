import 'package:flutter/material.dart';

import '../../../../../core/core.dart';

/// Site row with name, meta line and a status badge. Used for configured
/// sources and per-site import results.
class ScraperSiteTile extends StatelessWidget {
  const ScraperSiteTile({
    super.key,
    required this.name,
    required this.badge,
    this.subtitle,
    this.badgeTone = EdsTone.neutral,
  });

  final String name;
  final String? subtitle;
  final String badge;
  final EdsTone badgeTone;

  @override
  Widget build(BuildContext context) {
    return EdsListTile(
      title: name,
      titleStyle: AppTextStyles.itemTitleLarge,
      subtitle: subtitle,
      trailing: EdsBadge(badge, tone: badgeTone),
    );
  }
}
