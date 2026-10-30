import 'package:flutter/material.dart';

import '../../../core/core.dart';
import '../../../core/di/injection.dart';
import '../auth/presentation/sign_out.dart';

/// Pieces shared by the onboarding steps (profile, store), which use the
/// sign up layout: [OnboardingLogout] over the illustration, an
/// [OnboardingProgressLine] under it and an [OnboardingStageTrail] at the
/// bottom.

/// "Log out", top-right over the illustration.
class OnboardingLogout extends StatelessWidget {
  const OnboardingLogout({super.key});

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () => signOutToLogIn(context),
      style: TextButton.styleFrom(foregroundColor: AppColors.crimson),
      child: Text(
        'Log out',
        style: AppTextStyles.link.copyWith(color: AppColors.crimson),
      ),
    );
  }
}

/// The line under the illustration, filling with Crimson step by step.
class OnboardingProgressLine extends StatelessWidget {
  const OnboardingProgressLine({
    super.key,
    required this.stage,
    required this.step,
    required this.total,
  });

  final OnboardingStep stage;
  final int step;
  final int total;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '${stage.label} step $step of $total',
      child: SizedBox(
        height: 3,
        child: ColoredBox(
          color: AppColors.skeleton,
          child: AnimatedFractionallySizedBox(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
            alignment: Alignment.centerLeft,
            widthFactor: step / total,
            child: const ColoredBox(color: AppColors.crimson),
          ),
        ),
      ),
    );
  }
}

/// "✓ Profile  ›  Store  ›  KYC" at the very bottom, 10px above the safe
/// area, for the signed-in role: finished stages ticked, [current]
/// Crimson. Empty for roles with a single stage.
class OnboardingStageTrail extends StatelessWidget {
  const OnboardingStageTrail(this.current, {super.key});

  final OnboardingStep current;

  @override
  Widget build(BuildContext context) {
    final role = sl<AuthSession>().role ?? AppRole.customer;
    final stages = onboardingStages(role);
    final index = stages.indexOf(current);
    if (stages.length < 2 || index < 0) return const SizedBox.shrink();
    final parts = <Widget>[];
    for (var i = 0; i < stages.length; i++) {
      if (i > 0) {
        parts.add(
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.sm),
            child: Icon(Icons.chevron_right, size: 16, color: AppColors.gray),
          ),
        );
      }
      final done = i < index;
      final active = i == index;
      parts.add(
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (done) ...[
              const Icon(
                Icons.check_circle,
                size: 14,
                color: AppColors.crimson,
              ),
              const SizedBox(width: AppSpacing.xxs),
            ],
            Text(
              stages[i].label,
              style: AppTextStyles.label.copyWith(
                color: active
                    ? AppColors.crimson
                    : done
                    ? AppColors.ink
                    : AppColors.gray,
                fontWeight: active ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.xs,
          AppSpacing.lg,
          10,
        ),
        child: Semantics(
          label:
              'Onboarding: ${stages[index].label}, '
              '${index + 1} of ${stages.length}',
          child: ExcludeSemantics(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: parts,
            ),
          ),
        ),
      ),
    );
  }
}
