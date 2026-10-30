import 'package:flutter/material.dart';

import '../theme/theme.dart';
import 'eds_card.dart';
import 'eds_tone.dart';

/// Big number + caption card ("48 Active listings").
class EdsStatTile extends StatelessWidget {
  const EdsStatTile({
    super.key,
    required this.value,
    required this.label,
    this.tone = EdsTone.success,
    this.onTap,
  });

  final String value;
  final String label;
  final EdsTone tone;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final color = tone.foreground;
    return EdsCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(value, style: AppTextStyles.stat.copyWith(color: color)),
          AppSpacing.gapSm,
          Text(label, style: AppTextStyles.bodySecondary),
        ],
      ),
    );
  }
}
