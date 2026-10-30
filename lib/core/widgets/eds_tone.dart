import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Semantic color pairs shared by banners, badges, avatars and stats.
/// Success is Mustard (never green); errors are Ink (never red).
enum EdsTone {
  success,
  warning,
  danger,
  neutral;

  Color get background => switch (this) {
    EdsTone.success => AppColors.mustard,
    EdsTone.warning => AppColors.secondaryTint,
    EdsTone.danger || EdsTone.neutral => AppColors.sectionBackground,
  };

  /// Ink on every tinted fill (text on Mustard is never White); Gray for
  /// neutral helper content.
  Color get foreground => switch (this) {
    EdsTone.neutral => AppColors.gray,
    _ => AppColors.ink,
  };
}
