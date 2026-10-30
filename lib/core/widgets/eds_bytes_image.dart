import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../theme/theme.dart';

/// A picture from bytes the server sent. Those can be corrupt (a bad
/// placeholder, a truncated upload); a plain `Image.memory` would then log
/// an exception and paint nothing. This shows [fallback] instead — by
/// default a quiet "Couldn't load" panel, [onDark] for a viewer on Ink.
class EdsBytesImage extends StatelessWidget {
  const EdsBytesImage(
    this.bytes, {
    super.key,
    this.fit = BoxFit.cover,
    this.fallback,
    this.onDark = false,
    this.gaplessPlayback = false,
  });

  final Uint8List bytes;
  final BoxFit fit;
  final Widget? fallback;
  final bool onDark;
  final bool gaplessPlayback;

  @override
  Widget build(BuildContext context) {
    return Image.memory(
      bytes,
      fit: fit,
      gaplessPlayback: gaplessPlayback,
      errorBuilder: (_, _, _) => fallback ?? _CouldNotLoad(onDark: onDark),
    );
  }
}

class _CouldNotLoad extends StatelessWidget {
  const _CouldNotLoad({required this.onDark});

  final bool onDark;

  @override
  Widget build(BuildContext context) {
    final color = onDark ? AppColors.onCrimsonMuted : AppColors.gray;
    return ColoredBox(
      color: onDark ? AppColors.none : AppColors.sectionBackground,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.broken_image_outlined, size: 28, color: color),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Couldn’t load',
              style: AppTextStyles.caption.copyWith(color: color),
            ),
          ],
        ),
      ),
    );
  }
}
