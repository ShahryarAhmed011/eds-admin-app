import 'package:flutter/material.dart';

import '../theme/theme.dart';

/// EDS logo (figma_ref/logo02.html): a Crimson "EDS" wordmark with a
/// doorbell dot as its full stop, a Mustard step bar and the tagline.
///
/// When [animate] is on, the dot rings with ripples, the letters drop in
/// from right to left, then the bar and tagline appear ([duration] in
/// total). Reduce-motion
/// settings show the final frame. Scales down to fit narrow parents.
class EdsLogo extends StatefulWidget {
  const EdsLogo({
    super.key,
    this.size = 104,
    this.animate = true,
    this.showTagline = true,
  });

  /// Total length of the intro animation.
  static const duration = Duration(milliseconds: 2800);

  static const tagline = 'Quick delivery at your doorstep';

  /// Font size of the wordmark; every other measure scales with it.
  final double size;
  final bool animate;
  final bool showTagline;

  @override
  State<EdsLogo> createState() => _EdsLogoState();
}

class _EdsLogoState extends State<EdsLogo> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: EdsLogo.duration,
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final still = !widget.animate || MediaQuery.disableAnimationsOf(context);
    if (still) {
      _controller.value = 1;
    } else if (!_controller.isAnimating && _controller.value == 0) {
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: widget.showTagline ? 'EDS. ${EdsLogo.tagline}' : 'EDS',
      child: ExcludeSemantics(
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, _) => _LogoFrame(
              seconds: _controller.value * _seconds,
              size: widget.size,
              showTagline: widget.showTagline,
            ),
          ),
        ),
      ),
    );
  }

  static final _seconds = EdsLogo.duration.inMilliseconds / 1000;
}

/// One frame of the logo at [seconds] into the animation.
class _LogoFrame extends StatelessWidget {
  const _LogoFrame({
    required this.seconds,
    required this.size,
    required this.showTagline,
  });

  final double seconds;
  final double size;
  final bool showTagline;

  static const _snap = Cubic(0.2, 0.8, 0.2, 1);

  /// Letters before the dot, with their drop-in delays (seconds).
  static const _letters = [('E', 1.1), ('D', 0.9), ('S', 0.7)];

  /// CSS pixel sizes in the design are relative to a 104px wordmark.
  double _px(double value) => size * value / 104;

  /// Eased progress of a step that starts at [delay] and lasts [length].
  double _progress(double delay, double length, [Curve curve = _snap]) =>
      curve.transform(((seconds - delay) / length).clamp(0.0, 1.0));

  @override
  Widget build(BuildContext context) {
    final bar = _progress(1.9, 0.5, Curves.easeOut);
    final tag = _progress(2.2, 0.6, Curves.easeOut);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            for (final (letter, delay) in _letters) _letter(letter, delay),
            _DoorbellDot(seconds: seconds, size: size),
          ],
        ),
        if (showTagline) ...[
          SizedBox(height: _px(16)),
          // Fixed-width slot so the layout doesn't shift as the bar grows.
          SizedBox(
            width: _px(120),
            height: _px(5),
            child: Align(
              alignment: Alignment.center,
              child: Container(
                width: _px(120) * bar,
                decoration: BoxDecoration(
                  color: AppColors.mustard,
                  borderRadius: BorderRadius.circular(_px(3)),
                ),
              ),
            ),
          ),
          SizedBox(height: _px(14)),
          Opacity(
            opacity: tag,
            child: Transform.translate(
              offset: Offset(0, _px(12) * (1 - tag)),
              child: Text(
                EdsLogo.tagline,
                maxLines: 1,
                style: TextStyle(
                  fontFamily: _fontFamily,
                  fontSize: _px(21),
                  fontWeight: FontWeight.w500,
                  letterSpacing: _px(21) * 0.02,
                  color: AppColors.ink,
                  height: 1.2,
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _letter(String letter, double delay) {
    final t = _progress(delay, 0.55);
    return Opacity(
      opacity: t,
      child: Transform.translate(
        offset: Offset(0, -_px(22) * (1 - t)),
        child: Transform.scale(
          scale: 1.2 - 0.2 * t,
          child: Text(
            letter,
            style: TextStyle(
              fontFamily: _fontFamily,
              fontSize: size,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.03 * size,
              color: AppColors.crimson,
              height: 1,
              // CSS line-height splits leading evenly; match it so the
              // dot lines up with the letters as in the design.
              leadingDistribution: TextLeadingDistribution.even,
            ),
          ),
        ),
      ),
    );
  }
}

const _fontFamily = 'Outfit';

/// The full stop: a Crimson dot with a White ring that pops like a
/// doorbell while three rings ripple out.
class _DoorbellDot extends StatelessWidget {
  const _DoorbellDot({required this.seconds, required this.size});

  final double seconds;
  final double size;

  static const _rippleDelays = [0.6, 0.85, 1.1];
  static const _rippleLength = 1.2;
  static const _bellLength = 0.9;

  /// edsBell keyframes: 0 → 1.12 → 1 → 0.8 → 1.06 → 1.
  static final _bell = TweenSequence<double>([
    TweenSequenceItem(tween: Tween(begin: 0, end: 1.12), weight: 45),
    TweenSequenceItem(tween: Tween(begin: 1.12, end: 1), weight: 15),
    TweenSequenceItem(tween: Tween(begin: 1, end: 0.8), weight: 12),
    TweenSequenceItem(tween: Tween(begin: 0.8, end: 1.06), weight: 16),
    TweenSequenceItem(tween: Tween(begin: 1.06, end: 1), weight: 12),
  ]);

  @override
  Widget build(BuildContext context) {
    final diameter = size * 0.36;
    final bell = const Cubic(
      0.2,
      0.8,
      0.2,
      1,
    ).transform((seconds / _bellLength).clamp(0.0, 1.0));
    return Padding(
      padding: EdgeInsets.only(left: size * 0.08, bottom: size * 0.04),
      child: SizedBox.square(
        dimension: diameter,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            for (final delay in _rippleDelays)
              _ripple(((seconds - delay) / _rippleLength).clamp(0.0, 1.0)),
            Transform.scale(
              scale: _bell.transform(bell),
              child: Container(
                decoration: const BoxDecoration(
                  color: AppColors.crimson,
                  shape: BoxShape.circle,
                ),
                padding: EdgeInsets.all(size * 0.09),
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.white,
                      width: size * 0.045,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// edsRipple: fades from 0.7 to 0 while growing from 0.4× to 3.2×.
  Widget _ripple(double t) {
    if (t <= 0 || t >= 1) return const SizedBox.shrink();
    final eased = Curves.easeOut.transform(t);
    return Positioned.fill(
      child: Opacity(
        opacity: 0.7 * (1 - eased),
        child: Transform.scale(
          scale: 0.4 + 2.8 * eased,
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.crimson, width: 2.5),
            ),
          ),
        ),
      ),
    );
  }
}
