import 'package:flutter/material.dart';

import '../theme/theme.dart';
import 'eds_badge.dart';
import 'eds_button.dart';
import 'eds_card.dart';
import 'eds_tone.dart';

/// CNIC / document upload card: letter preview, label, status, action.
class EdsDocumentTile extends StatelessWidget {
  const EdsDocumentTile({
    super.key,
    required this.letter,
    required this.label,
    required this.status,
    this.statusTone = EdsTone.success,
    this.actionLabel,
    this.onAction,
  });

  final String letter;
  final String label;
  final String status;
  final EdsTone statusTone;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return EdsCard(
      padding: const EdgeInsets.all(AppSpacing.sm),
      child: Column(
        children: [
          Container(
            height: 56,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.sectionBackground,
              borderRadius: AppRadius.smAll,
            ),
            child: Text(letter, style: AppTextStyles.headline),
          ),
          AppSpacing.gapMd,
          Text(label, style: AppTextStyles.itemTitle),
          AppSpacing.gapSm,
          EdsBadge(status, tone: statusTone),
          if (actionLabel != null) ...[
            AppSpacing.gapSm,
            EdsButton.text(label: actionLabel!, onPressed: onAction),
          ],
          AppSpacing.gapXs,
        ],
      ),
    );
  }
}
