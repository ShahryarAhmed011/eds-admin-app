import 'package:flutter/widgets.dart';

import '../../../core/core.dart';
import '../../../core/di/injection.dart';

/// The onboarding stepper for [step] when it's the signed-in account's
/// current step (null otherwise), with [subLabel] as its one sub-step.
Widget? onboardingStepperFor(OnboardingStep step, String subLabel) {
  final session = sl<AuthSession>();
  final role = session.role;
  if (role == null || session.onboardingStep != step) return null;
  final stages = onboardingStages(role);
  return EdsStepper(
    steps: [for (final stage in stages) stage.label],
    current: stages.indexOf(step),
    subStep: 0,
    subSteps: 1,
    subLabel: subLabel,
  );
}
