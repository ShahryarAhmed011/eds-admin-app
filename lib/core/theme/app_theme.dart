import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app_colors.dart';
import 'app_spacing.dart';
import 'app_text_styles.dart';

/// Light-only theme built from [AppColors]. Widgets read colors from here
/// or from [AppColors]; nothing else may hardcode one.
///
/// Flat by design: no elevation or shadows anywhere, only a 1px
/// Gray @ 20% border on cards, sheets and inputs.
abstract final class AppTheme {
  static ThemeData get light {
    final colorScheme = ColorScheme(
      brightness: Brightness.light,
      primary: AppColors.crimson,
      onPrimary: AppColors.white,
      primaryContainer: AppColors.primaryTint,
      onPrimaryContainer: AppColors.crimson,
      secondary: AppColors.mustard,
      onSecondary: AppColors.ink,
      secondaryContainer: AppColors.secondaryTint,
      onSecondaryContainer: AppColors.ink,
      tertiary: AppColors.mustard,
      onTertiary: AppColors.ink,
      surface: AppColors.white,
      onSurface: AppColors.ink,
      onSurfaceVariant: AppColors.gray,
      surfaceContainerLowest: AppColors.white,
      surfaceContainerLow: AppColors.sectionBackground,
      surfaceContainer: AppColors.white,
      surfaceContainerHigh: AppColors.white,
      surfaceContainerHighest: AppColors.white,
      surfaceTint: AppColors.none,
      outline: AppColors.border,
      outlineVariant: AppColors.skeleton,
      error: AppColors.ink,
      onError: AppColors.white,
      errorContainer: AppColors.sectionBackground,
      onErrorContainer: AppColors.ink,
      inverseSurface: AppColors.ink,
      onInverseSurface: AppColors.white,
      inversePrimary: AppColors.primaryTint,
      shadow: AppColors.none,
      scrim: AppColors.scrim,
    );

    final hairline = BorderSide(color: AppColors.border);
    final inputBorder = OutlineInputBorder(
      borderRadius: AppRadius.mdAll,
      borderSide: hairline,
    );
    final buttonShape = RoundedRectangleBorder(borderRadius: AppRadius.mdAll);
    const buttonPadding = EdgeInsets.symmetric(horizontal: AppSpacing.lg);
    const buttonSize = Size(0, AppSizes.buttonHeight);

    final primaryButtonStyle = ButtonStyle(
      elevation: const WidgetStatePropertyAll(0),
      shadowColor: const WidgetStatePropertyAll(AppColors.none),
      overlayColor: const WidgetStatePropertyAll(AppColors.none),
      minimumSize: const WidgetStatePropertyAll(buttonSize),
      padding: const WidgetStatePropertyAll(buttonPadding),
      shape: WidgetStatePropertyAll(buttonShape),
      textStyle: WidgetStatePropertyAll(AppTextStyles.button),
      backgroundColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.disabled)
            ? AppColors.skeleton
            : states.contains(WidgetState.pressed)
            ? AppColors.primaryPressed
            : AppColors.crimson,
      ),
      foregroundColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.disabled)
            ? AppColors.gray
            : AppColors.white,
      ),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      fontFamily: AppTextStyles.fontFamily,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.white,
      canvasColor: AppColors.white,
      shadowColor: AppColors.none,
      dividerColor: AppColors.border,
      splashFactory: InkSparkle.splashFactory,
      iconTheme: const IconThemeData(color: AppColors.ink),
      textTheme: TextTheme(
        displaySmall: AppTextStyles.display,
        headlineSmall: AppTextStyles.headline,
        titleLarge: AppTextStyles.title,
        titleMedium: AppTextStyles.sectionTitle,
        titleSmall: AppTextStyles.itemTitle,
        bodyLarge: AppTextStyles.bodyLarge,
        bodyMedium: AppTextStyles.body,
        bodySmall: AppTextStyles.caption,
        labelLarge: AppTextStyles.button,
        labelMedium: AppTextStyles.label,
        labelSmall: AppTextStyles.badge,
      ),
      appBarTheme: AppBarTheme(
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.ink,
        surfaceTintColor: AppColors.none,
        shadowColor: AppColors.none,
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: const IconThemeData(color: AppColors.ink),
        titleTextStyle: AppTextStyles.title,
      ),
      cardTheme: CardThemeData(
        color: AppColors.white,
        surfaceTintColor: AppColors.none,
        shadowColor: AppColors.none,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.mdAll,
          side: hairline,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(style: primaryButtonStyle),
      filledButtonTheme: FilledButtonThemeData(style: primaryButtonStyle),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          backgroundColor: AppColors.white,
          foregroundColor: AppColors.ink,
          disabledForegroundColor: AppColors.gray,
          minimumSize: buttonSize,
          padding: buttonPadding,
          textStyle: AppTextStyles.button,
          shape: buttonShape,
          side: hairline,
          elevation: 0,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.ink,
          disabledForegroundColor: AppColors.gray,
          textStyle: AppTextStyles.link,
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.white,
        selectedColor: AppColors.primaryTint,
        disabledColor: AppColors.skeleton,
        checkmarkColor: AppColors.crimson,
        surfaceTintColor: AppColors.none,
        shadowColor: AppColors.none,
        selectedShadowColor: AppColors.none,
        elevation: 0,
        pressElevation: 0,
        side: hairline,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.pillAll),
        labelStyle: AppTextStyles.label.copyWith(color: AppColors.ink),
        secondaryLabelStyle: AppTextStyles.label.copyWith(
          color: AppColors.crimson,
        ),
        iconTheme: const IconThemeData(color: AppColors.ink, size: 18),
      ),
      dividerTheme: DividerThemeData(
        color: AppColors.border,
        thickness: 1,
        space: 1,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.white,
        hintStyle: AppTextStyles.bodyLarge.copyWith(color: AppColors.gray),
        helperStyle: AppTextStyles.caption,
        errorStyle: AppTextStyles.caption.copyWith(color: AppColors.ink),
        prefixIconColor: AppColors.gray,
        suffixIconColor: AppColors.gray,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: 14,
        ),
        border: inputBorder,
        enabledBorder: inputBorder,
        disabledBorder: inputBorder,
        focusedBorder: inputBorder.copyWith(
          borderSide: const BorderSide(color: AppColors.ink, width: 1.5),
        ),
        errorBorder: inputBorder.copyWith(
          borderSide: const BorderSide(color: AppColors.ink),
        ),
        focusedErrorBorder: inputBorder.copyWith(
          borderSide: const BorderSide(color: AppColors.ink, width: 1.5),
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: AppColors.white,
        selectedItemColor: AppColors.crimson,
        unselectedItemColor: AppColors.gray,
        selectedIconTheme: const IconThemeData(color: AppColors.crimson),
        unselectedIconTheme: const IconThemeData(color: AppColors.gray),
        selectedLabelStyle: AppTextStyles.navLabel.copyWith(
          fontWeight: FontWeight.w700,
        ),
        unselectedLabelStyle: AppTextStyles.navLabel,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
      switchTheme: SwitchThemeData(
        thumbColor: const WidgetStatePropertyAll(AppColors.white),
        trackOutlineColor: const WidgetStatePropertyAll(AppColors.none),
        trackColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? AppColors.crimson
              : AppColors.gray,
        ),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? AppColors.crimson
              : AppColors.none,
        ),
        checkColor: const WidgetStatePropertyAll(AppColors.white),
        side: const BorderSide(color: AppColors.gray, width: 1.5),
      ),
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? AppColors.crimson
              : AppColors.gray,
        ),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: AppColors.ink,
        linearTrackColor: AppColors.skeleton,
        circularTrackColor: AppColors.none,
      ),
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: AppColors.ink,
        selectionColor: AppColors.primaryTint,
        selectionHandleColor: AppColors.crimson,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.white,
        surfaceTintColor: AppColors.none,
        shadowColor: AppColors.none,
        elevation: 0,
        barrierColor: AppColors.scrim,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.mdAll,
          side: hairline,
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: AppColors.white,
        surfaceTintColor: AppColors.none,
        shadowColor: AppColors.none,
        elevation: 0,
        modalElevation: 0,
        modalBarrierColor: AppColors.scrim,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppRadius.sheet),
          ),
        ),
      ),
    );
  }
}
