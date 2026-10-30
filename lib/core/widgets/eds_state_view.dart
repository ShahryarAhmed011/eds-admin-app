import 'package:flutter/material.dart';

import '../theme/theme.dart';
import 'eds_avatar.dart';
import 'eds_badge.dart';
import 'eds_button.dart';
import 'eds_tone.dart';

/// Centered hero for empty, error, success and "coming soon" states.
class EdsStateView extends StatelessWidget {
  const EdsStateView({
    super.key,
    required this.title,
    this.message,
    this.letter,
    this.icon,
    this.badge,
    this.tone = EdsTone.success,
    this.large = false,
  });

  final String title;
  final String? message;
  final String? letter;
  final IconData? icon;

  /// Optional pill above the title ("Phase 2 · Coming soon").
  final String? badge;
  final EdsTone tone;

  /// Use the display font for the title.
  final bool large;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxl),
      child: Column(
        children: [
          if (letter != null || icon != null)
            EdsAvatar(text: letter, icon: icon, size: 64, tone: tone),
          if (badge != null) ...[
            AppSpacing.gapXl,
            EdsBadge(badge!, tone: EdsTone.neutral),
          ],
          AppSpacing.gapXl,
          Text(
            title,
            textAlign: TextAlign.center,
            style: large
                ? AppTextStyles.display.copyWith(fontWeight: FontWeight.w500)
                : AppTextStyles.headline,
          ),
          if (message != null) ...[
            AppSpacing.gapMd,
            Text(
              message!,
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyLarge.copyWith(color: AppColors.gray),
            ),
          ],
        ],
      ),
    );
  }
}

/// Default loading indicator for bloc `Loading` states.
class EdsLoadingView extends StatelessWidget {
  const EdsLoadingView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.xxxl),
        child: CircularProgressIndicator(),
      ),
    );
  }
}

/// Default view for bloc `Failure` states.
class EdsErrorView extends StatelessWidget {
  const EdsErrorView({
    super.key,
    required this.message,
    this.onRetry,
    this.reference,
  });

  final String message;
  final VoidCallback? onRetry;

  /// API request id, shown so bug reports are traceable.
  final String? reference;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        EdsStateView(
          letter: '!',
          title: 'Something went wrong',
          message: message,
          tone: EdsTone.danger,
        ),
        if (reference != null) ...[
          Text('Reference: $reference', style: AppTextStyles.caption),
          AppSpacing.gapLg,
        ],
        if (onRetry != null)
          EdsButton.secondary(label: 'Retry', onPressed: onRetry),
      ],
    );
  }
}
