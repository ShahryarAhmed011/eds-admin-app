import 'dart:math' as math;
import 'dart:ui' show PathMetric;

import 'package:flutter/material.dart';

import '../theme/theme.dart';

/// A light running along a rounded box's edge: a crimson segment, about a
/// fifth of the way round, brightest in the middle and fading to nothing
/// at both ends, moved by [progress] (0–1 = one lap). Use it as a
/// `CustomPaint.foregroundPainter` driven by a repeating
/// `AnimationController` (3.6 s a lap reads well).
///
/// Parked: built for the Home shop chip on 2026-10-29 and taken off the
/// screen with it; kept here for when it's wanted again.
class EdsBorderBeamPainter extends CustomPainter {
  EdsBorderBeamPainter(this.progress) : super(repaint: progress);

  final Animation<double> progress;

  /// How much of the perimeter the glow covers, and how many short strokes
  /// of stepped opacity make up its fade.
  static const _fraction = 0.22;
  static const _pieces = 18;

  @override
  void paint(Canvas canvas, Size size) {
    final rrect = RRect.fromRectAndRadius(
      Offset.zero & size,
      const Radius.circular(AppRadius.md),
    ).deflate(0.5);
    final metric = (Path()..addRRect(rrect)).computeMetrics().first;
    final length = metric.length;
    final beam = length * _fraction;
    final head = progress.value * length;
    final step = beam / _pieces;
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;
    for (var i = 0; i < _pieces; i++) {
      final t = (i + 0.5) / _pieces;
      paint.color = AppColors.borderBeam(math.sin(math.pi * t));
      canvas.drawPath(
        _segment(metric, length, head - beam + i * step, step),
        paint,
      );
    }
  }

  /// [len] of the path from [from], wrapping past the end.
  static Path _segment(
    PathMetric metric,
    double length,
    double from,
    double len,
  ) {
    final start = ((from % length) + length) % length;
    final end = start + len;
    if (end <= length) return metric.extractPath(start, end);
    return metric.extractPath(start, length)
      ..addPath(metric.extractPath(0, end - length), Offset.zero);
  }

  @override
  bool shouldRepaint(EdsBorderBeamPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
