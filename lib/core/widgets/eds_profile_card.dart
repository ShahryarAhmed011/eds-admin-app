import 'package:flutter/material.dart';

import '../theme/theme.dart';
import 'eds_avatar.dart';
import 'eds_badge.dart';
import 'eds_card.dart';
import 'eds_list_tile.dart';
import 'eds_tone.dart';

/// Identity summary card: avatar, name, meta, badge and detail lines.
/// Used on account/profile/detail screens for every role.
class EdsProfileCard extends StatelessWidget {
  const EdsProfileCard({
    super.key,
    required this.name,
    required this.subtitle,
    this.badge,
    this.badgeTone = EdsTone.success,
    this.details = const [],
    this.onTap,
  });

  final String name;
  final String subtitle;
  final String? badge;
  final EdsTone badgeTone;

  /// Lines shown under a divider (phone number, address, CNIC...).
  final List<String> details;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return EdsCard(
      onTap: onTap,
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          EdsListTile(
            leading: EdsAvatar(text: name),
            title: name,
            subtitle: subtitle,
            titleStyle: AppTextStyles.itemTitleLarge,
            trailing: badge == null ? null : EdsBadge(badge!, tone: badgeTone),
          ),
          if (details.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                0,
                AppSpacing.lg,
                AppSpacing.lg,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (final line in details) ...[
                    AppSpacing.gapSm,
                    Text(line, style: AppTextStyles.bodyLarge),
                  ],
                ],
              ),
            ),
        ],
      ),
    );
  }
}
