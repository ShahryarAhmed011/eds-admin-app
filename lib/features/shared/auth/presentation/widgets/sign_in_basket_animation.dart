import 'package:flutter/material.dart';

import '../../../../../core/core.dart';

/// Looping sign-in header (figma_ref/baskit_animation.html): a Crimson
/// basket rises in, a coffee cup, milk, juice, chips and a burger drop into
/// it, the handle swings up and "ORDER READY" pops. A scooter rider pulls
/// up, the basket hops on, "ON THE WAY" pops and they ride off.
///
/// Drawn on the design's 680×360 canvas and scaled to fit. Reduce-motion
/// settings show the "order ready" frame.
class SignInBasketAnimation extends StatefulWidget {
  const SignInBasketAnimation({super.key});

  /// One full loop, as in the design.
  static const loop = Duration(milliseconds: 7800);

  @override
  State<SignInBasketAnimation> createState() => _SignInBasketAnimationState();
}

class _SignInBasketAnimationState extends State<SignInBasketAnimation>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: SignInBasketAnimation.loop,
  );

  /// Seconds into the loop shown when animations are off.
  static const _stillSeconds = 5.0;

  static final _loopSeconds = SignInBasketAnimation.loop.inMilliseconds / 1000;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _controller
        ..stop()
        ..value = _stillSeconds / _loopSeconds;
    } else if (!_controller.isAnimating) {
      _controller.repeat();
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
      image: true,
      label: 'A basket fills with groceries and rides off on a scooter',
      child: AspectRatio(
        aspectRatio: _BasketPainter.width / _BasketPainter.height,
        child: CustomPaint(
          painter: _BasketPainter(
            _controller,
            () => _controller.value * _loopSeconds,
          ),
        ),
      ),
    );
  }
}

/// Paints one frame at the controller's time. Coordinates are the SVG's
/// viewBox units; timings and curves are the CSS keyframes'.
class _BasketPainter extends CustomPainter {
  _BasketPainter(Listenable repaint, this._seconds) : super(repaint: repaint);

  static const width = 680.0;
  static const height = 360.0;

  final double Function() _seconds;

  // CSS timing functions from the design.
  static const _snap = Cubic(0.2, 0.8, 0.2, 1);
  static const _drop = Cubic(0.3, 0.9, 0.4, 1.1);
  static const _swing = Cubic(0.2, 0.8, 0.2, 1.2);
  static const _pop = Cubic(0.2, 0.8, 0.2, 1.3);
  static const _hop = Cubic(0.4, 0, 0.3, 1);
  static const _rideOff = Cubic(0.5, 0, 0.8, 0.4);

  /// Basket transform origin: bottom centre of the basket.
  static const _basketOrigin = Offset(340, 302);

  static const _squashStarts = [1.0, 1.5, 2.0, 2.5, 3.0];

  /// (drop delay, x, painter) for each item, back to front.
  static const _items = <(double, double, void Function(Canvas))>[
    (0.55, 276, _paintCoffee),
    (1.05, 306, _paintMilk),
    (1.55, 340, _paintJuice),
    (2.05, 380, _paintChips),
    (2.55, 414, _paintBurger),
  ];

  static final _orderReady = _pillLabel('ORDER READY', AppColors.ink);
  static final _onTheWay = _pillLabel('ON THE WAY', AppColors.white);

  /// Eased progress of a step that starts at [start] and lasts [length].
  static double _progress(double t, double start, double length, Curve c) =>
      c.transform(((t - start) / length).clamp(0.0, 1.0));

  @override
  void paint(Canvas canvas, Size size) {
    final t = _seconds();
    canvas
      ..save()
      ..scale(size.width / width)
      ..clipRect(const Rect.fromLTWH(0, 0, width, height));

    canvas.drawLine(
      const Offset(60, 331),
      const Offset(620, 331),
      _stroke(AppColors.ink, 1.5),
    );

    final rideX = 600 * _progress(t, 5.9, 0.9, _rideOff);
    _paintBasket(canvas, t, rideX);
    _paintPill(canvas, t, _orderReady, 140, AppColors.mustard, 3.9, 5.0);
    _paintPill(canvas, t, _onTheWay, 128, AppColors.crimson, 6.0, null);

    final slideX = -340 * (1 - _progress(t, 4.3, 0.7, _snap));
    canvas
      ..save()
      ..translate(210 + slideX + rideX, 330)
      ..scale(2);
    _paintScooter(canvas, t);
    canvas
      ..restore()
      ..restore();
  }

  // Basket ------------------------------------------------------------------

  void _paintBasket(Canvas canvas, double t, double rideX) {
    final rise = _progress(t, 0, 0.5, _snap);
    var dx = 0.0, dy = 30 * (1 - rise), scale = 1.0;
    if (t >= 5.1) {
      // b-hop: up and over onto the scooter, shrinking; eased per half.
      final u = ((t - 5.1) / 0.8).clamp(0.0, 1.0);
      if (u < 0.5) {
        final k = _progress(u, 0, 0.5, _hop);
        (dx, dy, scale) = (-100 * k, -120 * k, 1 - 0.3 * k);
      } else {
        final k = _progress(u, 0.5, 0.5, _hop);
        (dx, dy, scale) = (-100 - 80 * k, -120 + 130 * k, 0.7 - 0.25 * k);
      }
    }
    // Rides off with the scooter once it's on board.
    dx += rideX;

    canvas.saveLayer(null, Paint()..color = AppColors.layerOpacity(rise));
    _aroundOrigin(canvas, _basketOrigin, () {
      canvas
        ..translate(dx, dy)
        ..scale(scale);
    });

    final (sx, sy) = _squash(t);
    _aroundOrigin(canvas, _basketOrigin, () => canvas.scale(sx, sy));

    final shade = AppColors.crimsonShade;
    canvas.drawRect(
      const Rect.fromLTWH(260, 184, 160, 70),
      Paint()..color = shade,
    );
    for (final (delay, x, paintItem) in _items) {
      _paintDroppingItem(canvas, t - delay, x, paintItem);
    }
    canvas.drawPath(
      Path()
        ..moveTo(252, 196)
        ..relativeLineTo(176, 0)
        ..relativeLineTo(-14, 96)
        ..relativeQuadraticBezierTo(-2, 10, -12, 10)
        ..relativeLineTo(-124, 0)
        ..relativeQuadraticBezierTo(-10, 0, -12, -10)
        ..close(),
      Paint()..color = AppColors.crimson,
    );
    final slot = Paint()..color = AppColors.white;
    for (var row = 0; row < 3; row++) {
      for (var col = 0; col < 6; col++) {
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(268 + 4.0 * row + 26 * col, 212 + 24.0 * row, 12, 6),
            const Radius.circular(1.5),
          ),
          slot,
        );
      }
    }
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(244, 178, 192, 20),
        const Radius.circular(6),
      ),
      Paint()..color = shade,
    );

    // Handle swings up from its base.
    final handle = 0.06 + 0.94 * _progress(t, 3.3, 0.5, _swing);
    canvas.save();
    _aroundOrigin(canvas, const Offset(340, 186), () {
      canvas.scale(1, handle);
    });
    canvas
      ..drawPath(
        Path()
          ..moveTo(262, 186)
          ..arcToPoint(
            const Offset(418, 186),
            radius: const Radius.circular(78),
          ),
        _stroke(shade, 10),
      )
      ..restore()
      ..restore();
  }

  /// b-squash on every landing: 40% → scaleY .94 scaleX 1.03, then back.
  static (double, double) _squash(double t) {
    for (final start in _squashStarts) {
      final u = (t - start) / 0.3;
      if (u < 0 || u >= 1) continue;
      final k = u < 0.4
          ? _progress(u, 0, 0.4, Curves.easeOut)
          : 1 - _progress(u, 0.4, 0.6, Curves.easeOut);
      return (1 + 0.03 * k, 1 - 0.06 * k);
    }
    return (1, 1);
  }

  /// b-drop: falls 230 from above, fading in, with a small bounce.
  static void _paintDroppingItem(
    Canvas canvas,
    double local,
    double x,
    void Function(Canvas) paintItem,
  ) {
    if (local < 0) return;
    final f = (local / 0.55).clamp(0.0, 1.0);
    final opacity = f < 0.15
        ? _progress(f, 0, 0.15, _drop).clamp(0.0, 1.0)
        : 1.0;
    final double y;
    if (f < 0.7) {
      y = -230 * (1 - _progress(f, 0, 0.7, _drop));
    } else if (f < 0.85) {
      y = -8 * _progress(f, 0.7, 0.15, _drop);
    } else {
      y = -8 * (1 - _progress(f, 0.85, 0.15, _drop));
    }
    canvas
      ..saveLayer(null, Paint()..color = AppColors.layerOpacity(opacity))
      ..translate(x, 192 + y);
    paintItem(canvas);
    canvas.restore();
  }

  static void _paintCoffee(Canvas canvas) {
    final cup = Path()
      ..moveTo(-11, -51)
      ..relativeLineTo(22, 0)
      ..relativeLineTo(-3, 51)
      ..relativeLineTo(-16, 0)
      ..close();
    canvas
      ..drawRRect(
        RRect.fromRectAndRadius(
          const Rect.fromLTWH(-13, -58, 26, 7),
          const Radius.circular(2),
        ),
        Paint()..color = AppColors.ink,
      )
      ..drawPath(cup, Paint()..color = AppColors.white);
    _outline(canvas, cup);
    canvas
      ..drawPath(
        Path()
          ..moveTo(-10.2, -38)
          ..relativeLineTo(20.4, 0)
          ..relativeLineTo(-1.1, 18)
          ..relativeLineTo(-18.2, 0)
          ..close(),
        Paint()..color = AppColors.crimson,
      )
      ..drawCircle(const Offset(0, -29), 3, Paint()..color = AppColors.mustard);
  }

  static void _paintMilk(Canvas canvas) {
    _paintBottle(
      canvas,
      capTop: -76,
      neck: 14,
      bodyLength: 42,
      cap: AppColors.crimson,
      body: AppColors.white,
      labelTop: -40,
      label: AppColors.crimson,
      dotRadius: 3.5,
      dot: AppColors.white,
    );
  }

  static void _paintJuice(Canvas canvas) {
    _paintBottle(
      canvas,
      capTop: -78,
      neck: 12,
      bodyLength: 44,
      cap: AppColors.ink,
      body: AppColors.mustard,
      labelTop: -42,
      label: AppColors.white,
      dotRadius: 4,
      dot: AppColors.crimson,
    );
  }

  /// Milk and juice share one shape: cap, neck, shoulders, rounded body,
  /// a label band and a dot on it.
  static void _paintBottle(
    Canvas canvas, {
    required double capTop,
    required double neck,
    required double bodyLength,
    required Color cap,
    required Color body,
    required double labelTop,
    required Color label,
    required double dotRadius,
    required Color dot,
  }) {
    final top = capTop + 9;
    final shape = Path()
      ..moveTo(-neck / 2, top)
      ..relativeLineTo(neck, 0)
      ..relativeLineTo(0, 9)
      ..relativeQuadraticBezierTo(12, 4, 12, 16)
      ..relativeLineTo(0, bodyLength)
      ..relativeQuadraticBezierTo(0, 6, -6, 6)
      ..relativeLineTo(-(neck + 12), 0)
      ..relativeQuadraticBezierTo(-6, 0, -6, -6)
      ..relativeLineTo(0, -bodyLength)
      ..relativeQuadraticBezierTo(0, -12, 12, -16)
      ..close();
    canvas
      ..drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(-8, capTop, 16, 9),
          const Radius.circular(2),
        ),
        Paint()..color = cap,
      )
      ..drawPath(shape, Paint()..color = body);
    _outline(canvas, shape);
    canvas
      ..drawRect(Rect.fromLTWH(-18, labelTop, 36, 14), Paint()..color = label)
      ..drawCircle(Offset(0, labelTop + 7), dotRadius, Paint()..color = dot);
  }

  static void _paintChips(Canvas canvas) {
    final bag = Path()..moveTo(-21, -80);
    for (var i = 0; i < 8; i++) {
      bag.relativeLineTo(5, i.isEven ? 5 : -5);
    }
    bag.relativeLineTo(0, 72);
    for (var i = 0; i < 10; i++) {
      bag.relativeLineTo(-5, i.isEven ? 5 : -5);
    }
    bag.close();
    canvas.drawPath(bag, Paint()..color = AppColors.mustard);
    _outline(canvas, bag);
    final red = Paint()..color = AppColors.crimson;
    canvas
      ..drawRect(const Rect.fromLTWH(-21, -78, 42, 6), red)
      ..drawRect(const Rect.fromLTWH(-21, -14, 42, 6), red)
      ..drawCircle(const Offset(0, -45), 10, red)
      ..drawCircle(const Offset(0, -45), 4, Paint()..color = AppColors.white);
  }

  static void _paintBurger(Canvas canvas) {
    void layer(Rect rect, double radius, Color color) {
      final rrect = RRect.fromRectAndRadius(rect, Radius.circular(radius));
      canvas.drawRRect(rrect, Paint()..color = color);
      _outline(canvas, Path()..addRRect(rrect));
    }

    layer(const Rect.fromLTWH(-22, -14, 44, 14), 5, AppColors.mustard);
    layer(const Rect.fromLTWH(-24, -20, 48, 7), 2, AppColors.crimson);
    layer(const Rect.fromLTWH(-22, -25, 44, 6), 2, AppColors.white);
    final bun = Path()
      ..moveTo(-22, -25)
      ..relativeArcToPoint(
        const Offset(44, 0),
        radius: const Radius.elliptical(22, 16),
      )
      ..close();
    canvas.drawPath(bun, Paint()..color = AppColors.mustard);
    _outline(canvas, bun);
    final seed = Paint()..color = AppColors.ink;
    canvas
      ..drawCircle(const Offset(-8, -34), 1.5, seed)
      ..drawCircle(const Offset(2, -37), 1.5, seed)
      ..drawCircle(const Offset(11, -33), 1.5, seed);
  }

  // Pills -------------------------------------------------------------------

  static TextPainter _pillLabel(String text, Color color) => TextPainter(
    text: TextSpan(
      text: text,
      style: TextStyle(
        fontFamily: 'Outfit',
        fontSize: 11,
        fontWeight: FontWeight.w800,
        letterSpacing: 1,
        color: color,
        height: 1,
      ),
    ),
    textDirection: TextDirection.ltr,
  )..layout();

  /// Pops in at [showAt]; shrinks out at [hideAt] when given.
  static void _paintPill(
    Canvas canvas,
    double t,
    TextPainter label,
    double pillWidth,
    Color color,
    double showAt,
    double? hideAt,
  ) {
    if (t < showAt) return;
    final pop = _progress(t, showAt, 0.4, _pop);
    var opacity = pop.clamp(0.0, 1.0);
    var scale = 0.6 + 0.4 * pop;
    if (hideAt != null && t >= hideAt) {
      final out = _progress(t, hideAt, 0.3, Curves.easeIn);
      opacity = 1 - out;
      scale = 1 - 0.2 * out;
    }
    if (opacity <= 0) return;

    const center = Offset(340, 103);
    canvas.saveLayer(null, Paint()..color = AppColors.layerOpacity(opacity));
    _aroundOrigin(canvas, center, () => canvas.scale(scale));
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: center, width: pillWidth, height: 26),
        const Radius.circular(13),
      ),
      Paint()..color = color,
    );
    // Trailing letter spacing pushes the text left; add it back.
    label.paint(
      canvas,
      center - Offset((label.width - 1) / 2, label.height / 2),
    );
    canvas.restore();
  }

  // Scooter -----------------------------------------------------------------

  /// Rider and scooter in their own units (the design draws them at 2×).
  static void _paintScooter(Canvas canvas, double t) {
    _paintSpeedLines(canvas, t);
    final wheelFill = Paint()..color = AppColors.white;
    final wheelRim = _stroke(AppColors.ink, 2.5);
    for (final x in const [-11.0, 11.0]) {
      canvas
        ..drawCircle(Offset(x, -5.5), 5.5, wheelFill)
        ..drawCircle(Offset(x, -5.5), 5.5, wheelRim);
    }
    canvas
      ..drawPath(
        Path()
          ..moveTo(-13, -9)
          ..lineTo(6, -9)
          ..moveTo(11, -5.5)
          ..lineTo(16, -21)
          ..moveTo(13, -21)
          ..lineTo(19, -21),
        wheelRim,
      )
      ..drawLine(
        const Offset(-1, -9),
        const Offset(1, -16),
        _stroke(AppColors.ink, 3),
      )
      ..drawLine(
        const Offset(1, -16),
        const Offset(5, -26),
        _stroke(AppColors.crimson, 4.5),
      )
      ..drawLine(const Offset(4, -22), const Offset(14, -20), wheelRim)
      ..drawCircle(const Offset(6, -30), 4, Paint()..color = AppColors.ink)
      ..drawPath(
        Path()
          ..moveTo(2, -32)
          ..relativeArcToPoint(
            const Offset(8, 0),
            radius: const Radius.circular(4.5),
          )
          ..relativeLineTo(-8, 0)
          ..close(),
        Paint()..color = AppColors.mustard,
      );
  }

  /// Dashed (5 on, 5 off) lines that fade in as the rider leaves; the
  /// dashes march one period every 0.2s.
  static void _paintSpeedLines(Canvas canvas, double t) {
    if (t < 5.9) return;
    final f = ((t - 5.9) / 0.9).clamp(0.0, 1.0);
    final opacity = 0.7 * (f / 0.15).clamp(0.0, 1.0);
    final paint = _stroke(AppColors.crimson, 1.5);
    canvas.saveLayer(null, Paint()..color = AppColors.layerOpacity(opacity));
    final phase = (t / 0.2 % 1) * 10;
    const lines = [
      (-44.0, -24.0, -26.0),
      (-48.0, -26.0, -18.0),
      (-42.0, -24.0, -10.0),
    ];
    for (final (from, to, y) in lines) {
      for (var start = from + phase - 10; start < to; start += 10) {
        final a = start.clamp(from, to);
        final b = (start + 5).clamp(from, to);
        if (b > a) canvas.drawLine(Offset(a, y), Offset(b, y), paint);
      }
    }
    canvas.restore();
  }

  // Helpers -----------------------------------------------------------------

  /// Applies [transform] about [origin] (CSS transform-origin).
  static void _aroundOrigin(
    Canvas canvas,
    Offset origin,
    VoidCallback transform,
  ) {
    canvas.translate(origin.dx, origin.dy);
    transform();
    canvas.translate(-origin.dx, -origin.dy);
  }

  static Paint _stroke(Color color, double width) => Paint()
    ..color = color
    ..style = PaintingStyle.stroke
    ..strokeWidth = width
    ..strokeCap = StrokeCap.round
    ..strokeJoin = StrokeJoin.round;

  /// The design's 1.5 Ink outline on item shapes.
  static void _outline(Canvas canvas, Path path) =>
      canvas.drawPath(path, _stroke(AppColors.ink, 1.5));

  @override
  bool shouldRepaint(_BasketPainter oldDelegate) => false;
}
