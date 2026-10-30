import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../../core/core.dart';

/// Shared frame of the sign in and sign up screens: [AuthHero] on top, a
/// divider line, then [form]. Doesn't scroll: the form keeps its size and
/// the illustration takes what's left, up to 45% of the screen.
class AuthHeroLayout extends StatelessWidget {
  const AuthHeroLayout({
    super.key,
    required this.form,
    this.divider = const AuthHeroDivider(),
    this.onBack,
    this.heroTop,
    this.heroAction,
  });

  final Widget form;

  /// The line between the illustration and the form, e.g. sign up's
  /// progress.
  final Widget divider;

  /// Shows a back button over the illustration.
  final VoidCallback? onBack;

  /// Shown above the illustration, e.g. the onboarding stepper.
  final Widget? heroTop;

  /// Top-right over the illustration, opposite the back button (e.g.
  /// "Log out").
  final Widget? heroAction;

  @override
  Widget build(BuildContext context) {
    return CustomMultiChildLayout(
      delegate: _HeroLayoutDelegate(
        maxHeroHeight: MediaQuery.sizeOf(context).height * AuthHero.fraction,
      ),
      children: [
        LayoutId(
          id: _Slot.hero,
          child: AuthHero(onBack: onBack, top: heroTop, action: heroAction),
        ),
        LayoutId(id: _Slot.divider, child: divider),
        LayoutId(id: _Slot.form, child: form),
      ],
    );
  }
}

enum _Slot { hero, divider, form }

class _HeroLayoutDelegate extends MultiChildLayoutDelegate {
  _HeroLayoutDelegate({required this.maxHeroHeight});

  final double maxHeroHeight;

  @override
  void performLayout(Size size) {
    // Unbounded height, so the form takes its natural height.
    final natural = BoxConstraints.tightFor(width: size.width);
    final dividerHeight = layoutChild(_Slot.divider, natural).height;
    final formHeight = layoutChild(_Slot.form, natural).height;
    final heroHeight = (size.height - dividerHeight - formHeight).clamp(
      0.0,
      maxHeroHeight,
    );
    layoutChild(_Slot.hero, BoxConstraints.tight(Size(size.width, heroHeight)));
    positionChild(_Slot.hero, Offset.zero);
    positionChild(_Slot.divider, Offset(0, heroHeight));
    positionChild(_Slot.form, Offset(0, heroHeight + dividerHeight));
  }

  @override
  bool shouldRelayout(_HeroLayoutDelegate oldDelegate) =>
      oldDelegate.maxHeroHeight != maxHeroHeight;
}

/// Delivery illustration over the top 45% of the screen (status bar
/// included). Shrinks when the form needs the room: short phones, or the
/// keyboard open.
class AuthHero extends StatelessWidget {
  const AuthHero({super.key, this.onBack, this.top, this.action});

  /// Share of the screen height the illustration may take.
  static const fraction = 0.45;
  static const _illustration = 'assets/images/take_away.svg';

  final VoidCallback? onBack;

  /// Above the illustration, beside the back button.
  final Widget? top;

  /// Top-right, opposite the back button.
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * fraction,
      ),
      child: SizedBox(
        height: double.infinity,
        child: SafeArea(
          bottom: false,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  AppSpacing.lg,
                  AppSpacing.lg,
                  0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (top case final top?) ...[
                      // Clear of the back button's corner.
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.xxl,
                        ),
                        child: top,
                      ),
                      AppSpacing.gapMd,
                    ],
                    Expanded(
                      child: SvgPicture.asset(
                        _illustration,
                        semanticsLabel:
                            'A rider delivering a takeaway order to a door',
                      ),
                    ),
                  ],
                ),
              ),
              if (action case final action?)
                Align(
                  alignment: Alignment.topRight,
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.xs),
                    child: action,
                  ),
                ),
              if (onBack case final onBack?)
                Align(
                  alignment: Alignment.topLeft,
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.xs),
                    child: IconButton(
                      tooltip: 'Back',
                      icon: const Icon(Icons.arrow_back),
                      onPressed: onBack,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Hairline between the illustration and the form: light Crimson,
/// fading out towards both edges.
class AuthHeroDivider extends StatelessWidget {
  const AuthHeroDivider({super.key});

  static const _thickness = 1.0;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: _thickness,
      decoration: BoxDecoration(gradient: AppColors.heroDivider),
    );
  }
}

/// "[question] **[action]**" at the very bottom, 10px above the safe area,
/// e.g. "Don't have an account? Sign up". The action is a Crimson link.
class AuthBottomPrompt extends StatelessWidget {
  const AuthBottomPrompt({
    super.key,
    required this.question,
    required this.action,
    required this.onTap,
  });

  static const _bottomMargin = 10.0;

  final String question;
  final String action;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          0,
          AppSpacing.lg,
          _bottomMargin,
        ),
        // Shrinks rather than overflowing with large text sizes.
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('$question ', style: AppTextStyles.bodySecondary),
              // Compact link (a text button would add a 48px row).
              Semantics(
                button: true,
                child: InkWell(
                  onTap: onTap,
                  borderRadius: AppRadius.smAll,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.xxs,
                      vertical: AppSpacing.xs,
                    ),
                    child: Text(
                      action,
                      style: AppTextStyles.link.copyWith(
                        color: AppColors.crimson,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
