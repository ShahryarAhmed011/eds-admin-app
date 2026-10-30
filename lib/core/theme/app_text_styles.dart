import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Typography scale. All text in the app should come from here
/// (or from `Theme.of(context).textTheme`, which is built from it).
abstract final class AppTextStyles {
  /// Bundled in assets/fonts/inter (SIL Open Font License).
  static const fontFamily = 'Inter';

  static TextStyle get _base => const TextStyle(
    fontFamily: fontFamily,
    color: AppColors.ink,
    height: 1.35,
  );

  /// "Good to have you back." – large marketing headline.
  static TextStyle get display =>
      _base.copyWith(fontSize: 30, fontWeight: FontWeight.w400, height: 1.25);

  /// Bundled in assets/fonts/outfit: the display face of the brand
  /// wordmark, also a store's own name.
  static const displayFontFamily = 'Outfit';

  /// A store's name as the heading of its own screen.
  static TextStyle get storeName => const TextStyle(
    fontFamily: displayFontFamily,
    fontSize: 28,
    fontWeight: FontWeight.w800,
    height: 1.15,
    letterSpacing: -0.4,
    color: AppColors.ink,
  );

  /// The line under [storeName]: its type.
  static TextStyle get storeType => _base.copyWith(
    fontSize: 15,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.2,
    color: AppColors.gray,
  );

  /// "Check your messages", empty/error state titles.
  static TextStyle get headline =>
      _base.copyWith(fontSize: 24, fontWeight: FontWeight.w700, height: 1.25);

  /// App bar title.
  static TextStyle get title =>
      _base.copyWith(fontSize: 20, fontWeight: FontWeight.w700, height: 1.2);

  /// Section / card headings ("Bring your shop online").
  static TextStyle get sectionTitle =>
      _base.copyWith(fontSize: 17, fontWeight: FontWeight.w700);

  /// List item title.
  static TextStyle get itemTitle =>
      _base.copyWith(fontSize: 14, fontWeight: FontWeight.w600);

  /// Prominent row title (shop, account and queue rows).
  static TextStyle get itemTitleLarge => itemTitle.copyWith(fontSize: 15);

  static TextStyle get bodyLarge =>
      _base.copyWith(fontSize: 15, fontWeight: FontWeight.w400);

  static TextStyle get body =>
      _base.copyWith(fontSize: 13, fontWeight: FontWeight.w400);

  static TextStyle get bodySecondary => body.copyWith(color: AppColors.gray);

  static TextStyle get label => _base.copyWith(
    fontSize: 13,
    fontWeight: FontWeight.w500,
    color: AppColors.gray,
  );

  static TextStyle get caption => _base.copyWith(
    fontSize: 11.5,
    fontWeight: FontWeight.w400,
    color: AppColors.gray,
  );

  /// Small uppercase section labels.
  static TextStyle get eyebrow => _base.copyWith(
    fontSize: 10.5,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.4,
    color: AppColors.gray,
  );

  static TextStyle get button =>
      _base.copyWith(fontSize: 15, fontWeight: FontWeight.w700);

  static TextStyle get link => _base.copyWith(
    fontSize: 14,
    fontWeight: FontWeight.w700,
    color: AppColors.ink,
  );

  static TextStyle get badge =>
      _base.copyWith(fontSize: 11, fontWeight: FontWeight.w700);

  static TextStyle get price => _base.copyWith(
    fontSize: 15,
    fontWeight: FontWeight.w700,
    color: AppColors.ink,
  );

  static TextStyle get priceLarge => price.copyWith(fontSize: 24);

  static TextStyle get stat =>
      _base.copyWith(fontSize: 30, fontWeight: FontWeight.w700, height: 1.1);

  static TextStyle get navLabel => _base.copyWith(fontSize: 10.5);
}
