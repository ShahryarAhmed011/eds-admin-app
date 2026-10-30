import 'package:flutter/material.dart';

import '../theme/theme.dart';
import 'eds_tone.dart';

/// Small pill status label ("Verified", "Pending", "Flagged").
class EdsBadge extends StatelessWidget {
  const EdsBadge(this.label, {super.key, this.tone = EdsTone.success});

  final String label;
  final EdsTone tone;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: tone.background,
        borderRadius: AppRadius.pillAll,
      ),
      child: Text(
        label,
        style: AppTextStyles.badge.copyWith(color: tone.foreground),
      ),
    );
  }
}

/// Circular count bubble used in queue lists.
class EdsCountBadge extends StatelessWidget {
  const EdsCountBadge(this.count, {super.key, this.tone = EdsTone.success});

  final int count;
  final EdsTone tone;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
      decoration: BoxDecoration(
        color: tone.background,
        borderRadius: AppRadius.pillAll,
      ),
      child: Text(
        '$count',
        style: AppTextStyles.badge.copyWith(color: tone.foreground),
      ),
    );
  }
}
