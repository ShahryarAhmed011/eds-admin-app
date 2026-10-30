import 'package:flutter/material.dart';

import '../theme/theme.dart';
import 'eds_tone.dart';

/// Rounded-square tile showing the first letter of a name or an icon.
/// Stands in for product/shop/user imagery throughout the designs.
class EdsAvatar extends StatelessWidget {
  const EdsAvatar({
    super.key,
    this.text,
    this.icon,
    this.size = AppSizes.avatar,
    this.tone = EdsTone.neutral,
    this.solid = false,
  }) : assert(text != null || icon != null);

  /// Only the first character is shown.
  final String? text;
  final IconData? icon;
  final double size;
  final EdsTone tone;

  /// Ink background with a white glyph (e.g. the "E" logo tile).
  final bool solid;

  @override
  Widget build(BuildContext context) {
    final background = solid ? AppColors.ink : tone.background;
    final foreground = solid ? AppColors.white : tone.foreground;
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(size * 0.2),
      ),
      child: icon != null
          ? Icon(icon, color: foreground, size: size * 0.45)
          : Text(
              text!.isEmpty ? '' : text!.characters.first.toUpperCase(),
              style: AppTextStyles.title.copyWith(
                fontSize: size * 0.42,
                color: foreground,
              ),
            ),
    );
  }
}
