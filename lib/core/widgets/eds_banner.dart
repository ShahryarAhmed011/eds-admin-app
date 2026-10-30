import 'package:flutter/material.dart';

import '../theme/theme.dart';
import 'eds_tone.dart';

/// Tinted info block with a bold title and supporting message.
class EdsBanner extends StatelessWidget {
  const EdsBanner({
    super.key,
    required this.title,
    this.message,
    this.tone = EdsTone.neutral,
  });

  final String title;
  final String? message;
  final EdsTone tone;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: tone.background,
        borderRadius: AppRadius.mdAll,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTextStyles.itemTitle.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.ink,
            ),
          ),
          if (message != null) ...[
            const SizedBox(height: AppSpacing.xxs),
            Text(
              message!,
              style: AppTextStyles.body.copyWith(color: tone.foreground),
            ),
          ],
        ],
      ),
    );
  }
}
