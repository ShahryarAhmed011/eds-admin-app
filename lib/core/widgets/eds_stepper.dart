import 'package:flutter/material.dart';

import '../theme/theme.dart';

/// Onboarding progress: the main steps in a row (done ✓, current, next),
/// and the current step's sub-steps as segments with a caption.
class EdsStepper extends StatelessWidget {
  const EdsStepper({
    super.key,
    required this.steps,
    required this.current,
    required this.subStep,
    required this.subSteps,
    required this.subLabel,
  });

  /// Main step labels, e.g. Profile, Store, KYC.
  final List<String> steps;
  final int current;

  /// 0-based sub-step of [current], out of [subSteps].
  final int subStep;
  final int subSteps;
  final String subLabel;

  static const _node = 28.0;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label:
          '${steps[current]}, step ${current + 1} of ${steps.length}. '
          '$subLabel, ${subStep + 1} of $subSteps',
      child: ExcludeSemantics(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (steps.length > 1) ...[
              EdsMainSteps(steps: steps, current: current),
              AppSpacing.gapLg,
            ],
            Row(
              children: [
                for (var i = 0; i < subSteps; i++) ...[
                  if (i > 0) AppSpacing.gapXs,
                  Expanded(
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      height: 4,
                      decoration: BoxDecoration(
                        color: i <= subStep
                            ? AppColors.crimson
                            : AppColors.skeleton,
                        borderRadius: AppRadius.pillAll,
                      ),
                    ),
                  ),
                ],
              ],
            ),
            AppSpacing.gapSm,
            Text(
              '${subLabel.toUpperCase()} · STEP ${subStep + 1} OF $subSteps',
              style: AppTextStyles.eyebrow.copyWith(color: AppColors.crimson),
            ),
          ],
        ),
      ),
    );
  }
}

/// The main onboarding steps alone (Profile · Store · KYC): done ✓,
/// current and upcoming nodes joined by lines.
class EdsMainSteps extends StatelessWidget {
  const EdsMainSteps({super.key, required this.steps, required this.current});

  final List<String> steps;
  final int current;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < steps.length; i++) ...[
          if (i > 0)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: EdsStepper._node / 2 - 1),
                child: Container(
                  height: 2,
                  color: i <= current ? AppColors.crimson : AppColors.border,
                ),
              ),
            ),
          _node(i),
        ],
      ],
    );
  }

  Widget _node(int i) {
    final done = i < current;
    final active = i == current;
    return SizedBox(
      width: 64,
      child: Column(
        children: [
          Container(
            width: EdsStepper._node,
            height: EdsStepper._node,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: done ? AppColors.crimson : AppColors.white,
              shape: BoxShape.circle,
              border: Border.all(
                color: done || active ? AppColors.crimson : AppColors.border,
                width: active ? 2 : 1,
              ),
            ),
            child: done
                ? const Icon(Icons.check, size: 16, color: AppColors.white)
                : Text(
                    '${i + 1}',
                    style: AppTextStyles.badge.copyWith(
                      color: active ? AppColors.crimson : AppColors.gray,
                    ),
                  ),
          ),
          AppSpacing.gapXs,
          Text(
            steps[i],
            textAlign: TextAlign.center,
            style: AppTextStyles.caption.copyWith(
              color: active || done ? AppColors.ink : AppColors.gray,
              fontWeight: active ? FontWeight.w700 : FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}
