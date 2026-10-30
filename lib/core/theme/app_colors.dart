import 'package:flutter/material.dart';

/// The app's only colors. Five base values; every other shade is one of
/// them at an opacity. No other file may use `Colors.*` or a raw hex value.
///
/// Where each color may appear:
/// - [white]: every background (screens, cards, sheets, app bar); text on
///   [crimson].
/// - [ink]: all text and icons, dark secondary buttons, errors and
///   out-of-stock text; text on [mustard].
/// - [gray]: helper text, placeholders, strikethrough prices, inactive icons.
/// - [crimson]: primary CTAs, active tab, cart badge, selected states, the
///   `EdsToast` border and icon, and sign in / sign up field highlights
///   (icons, focus, errors). Otherwise never body text, icons at rest or
///   decoration.
/// - [mustard]: offers, ratings, delivery-time pills, savings tags, success.
///   Never on buttons.
abstract final class AppColors {
  static const white = Color(0xFFFFFFFF);
  static const ink = Color(0xFF141414);
  static const gray = Color(0xFF8A8A94);
  static const crimson = Color(0xFFE0243A);
  static const mustard = Color(0xFFF5B300);

  /// "Verified" chips on contact details.
  static const verified = Color(0xFF15803D);

  /// Fully transparent; for "no fill" slots that require a color.
  static const none = Colors.transparent;

  // Derived (opacity on the base colors only).

  /// Borders and dividers: Gray @ 20%.
  static Color get border => gray.withValues(alpha: 0.20);

  /// Section / list background: Gray @ 5%.
  static Color get sectionBackground => gray.withValues(alpha: 0.05);

  /// Home dashboard tiles: a clear Gray @ 35% line on White.
  static Color get tileBorder => gray.withValues(alpha: 0.35);

  /// Skeleton loaders, disabled fills, outlineVariant: Gray @ 12%.
  static Color get skeleton => gray.withValues(alpha: 0.12);

  /// Selected chip / primary tint: Crimson @ 10%.
  static Color get primaryTint => crimson.withValues(alpha: 0.10);

  /// Pressed primary button: Crimson overlaid with Ink @ 12%.
  static Color get primaryPressed =>
      Color.alphaBlend(ink.withValues(alpha: 0.12), crimson);

  /// Shaded crimson for the inside and rim of illustrations (the sign-in
  /// basket): Crimson overlaid with Ink @ 20%.
  static Color get crimsonShade =>
      Color.alphaBlend(ink.withValues(alpha: 0.20), crimson);

  /// Secondary text on a Crimson header: White @ 80%.
  static Color get onCrimsonMuted => white.withValues(alpha: 0.80);

  /// Icon circle on a Crimson header: White @ 15%.
  static Color get onCrimsonTint => white.withValues(alpha: 0.15);

  /// Hairline under the sign-in illustration: Crimson @ 45% in the middle,
  /// fading out at both edges.
  static LinearGradient get heroDivider => LinearGradient(
    colors: [
      crimson.withValues(alpha: 0),
      crimson.withValues(alpha: 0.45),
      crimson.withValues(alpha: 0),
    ],
  );

  /// Selected option card (sign up role): Crimson @ 6% at the top-left,
  /// fading to Crimson @ 1%.
  static LinearGradient get selectedCardGradient => LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [crimson.withValues(alpha: 0.06), crimson.withValues(alpha: 0.01)],
  );

  /// Paint color for `Canvas.saveLayer` that draws the layer at [opacity]
  /// (custom-painted illustrations fading in and out).
  static Color layerOpacity(double opacity) => white.withValues(alpha: opacity);

  /// `EdsBorderBeamPainter`: Crimson at [strength] (0–1), full in the
  /// middle of the beam and clear at both ends.
  static Color borderBeam(double strength) =>
      crimson.withValues(alpha: strength);

  /// Toast background (`EdsToast`): Crimson @ 8% on White, opaque so the
  /// screen underneath doesn't show through.
  static Color get toastBackground =>
      Color.alphaBlend(crimson.withValues(alpha: 0.08), white);

  /// Offer / success pill background: Mustard @ 15%.
  static Color get secondaryTint => mustard.withValues(alpha: 0.15);

  /// Modal barrier behind sheets and dialogs: Ink @ 55%.
  /// Soft off-white page behind white cards (account and detail screens).
  static Color get canvas =>
      Color.alphaBlend(gray.withValues(alpha: 0.07), white);

  static Color get verifiedTint => verified.withValues(alpha: 0.12);

  /// Over a cover image: darker at the top (status bar, buttons) and the
  /// bottom (the title), clear in the middle.
  static LinearGradient get coverScrim => LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      ink.withValues(alpha: 0.35),
      ink.withValues(alpha: 0.0),
      ink.withValues(alpha: 0.70),
    ],
    stops: const [0.0, 0.4, 1.0],
  );

  /// Over a cover image with nothing written on it: darker only at the top
  /// (status bar, buttons), clear from 45% down.
  static LinearGradient get coverTopScrim => LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [ink.withValues(alpha: 0.35), ink.withValues(alpha: 0.0)],
    stops: const [0.0, 0.45],
  );

  /// Quiet chevron at the end of tappable rows.
  static Color get chevron => gray.withValues(alpha: 0.70);

  static Color get scrim => ink.withValues(alpha: 0.55);

  /// Frosted round button over a cover photo (settings, camera): Ink @ 30%
  /// behind a blur, with a White @ 25% hairline so it reads on any picture.
  static Color get glass => ink.withValues(alpha: 0.30);
  static Color get glassBorder => white.withValues(alpha: 0.25);
}
