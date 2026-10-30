import 'package:flutter/material.dart';

import '../../../../../core/core.dart';
import '../../domain/entities/location_level.dart';

/// Card listing the current choice at each picker level. Tapping a row
/// reopens that level.
class LocationSummaryCard extends StatelessWidget {
  const LocationSummaryCard({
    super.key,
    required this.selection,
    required this.onLevelTap,
  });

  final Map<LocationLevel, String> selection;
  final ValueChanged<LocationLevel> onLevelTap;

  @override
  Widget build(BuildContext context) {
    return EdsGroupCard(
      showDividers: true,
      children: [
        for (final level in LocationLevel.pickerLevels)
          InkWell(
            onTap: () => onLevelTap(level),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Row(
                children: [
                  SizedBox(
                    width: 104,
                    child: Text(
                      level.label,
                      style: AppTextStyles.bodySecondary,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      selection[level] ?? 'Not selected',
                      style: selection[level] == null
                          ? AppTextStyles.bodySecondary
                          : AppTextStyles.itemTitle,
                    ),
                  ),
                  const Icon(Icons.chevron_right, color: AppColors.ink),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
