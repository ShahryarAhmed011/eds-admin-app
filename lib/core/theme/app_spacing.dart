import 'package:flutter/widgets.dart';

abstract final class AppSpacing {
  static const xxs = 2.0;
  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 12.0;
  static const lg = 16.0;
  static const xl = 20.0;
  static const xxl = 24.0;
  static const xxxl = 32.0;

  /// Horizontal gutter used by every screen.
  static const screen = lg;
  static const screenPadding = EdgeInsets.all(lg);

  static const gapXs = SizedBox(height: xs, width: xs);
  static const gapSm = SizedBox(height: sm, width: sm);
  static const gapMd = SizedBox(height: md, width: md);
  static const gapLg = SizedBox(height: lg, width: lg);
  static const gapXl = SizedBox(height: xl, width: xl);
  static const gapXxl = SizedBox(height: xxl, width: xxl);
}

abstract final class AppRadius {
  static const sm = 8.0;
  static const md = 12.0;
  static const pill = 999.0;
  static const sheet = 20.0;

  static const smAll = BorderRadius.all(Radius.circular(sm));
  static const mdAll = BorderRadius.all(Radius.circular(md));
  static const pillAll = BorderRadius.all(Radius.circular(pill));
}

abstract final class AppSizes {
  static const buttonHeight = 48.0;
  static const inputHeight = 48.0;
  static const avatar = 44.0;
  static const iconSm = 18.0;
  static const icon = 24.0;
}
