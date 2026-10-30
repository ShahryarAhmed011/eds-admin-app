import 'package:flutter/material.dart';

import '../theme/theme.dart';
import 'eds_card.dart';
import 'eds_list_tile.dart';

/// Card with a title, subtitle and switch ("Shop is live").
class EdsToggleCard extends StatelessWidget {
  const EdsToggleCard({
    super.key,
    required this.title,
    required this.value,
    required this.onChanged,
    this.subtitle,
  });

  final String title;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) {
    return EdsCard(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: EdsListTile(
        title: title,
        subtitle: subtitle,
        titleStyle: AppTextStyles.itemTitleLarge,
        trailing: Switch(value: value, onChanged: onChanged),
      ),
    );
  }
}
