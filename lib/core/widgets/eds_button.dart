import 'package:flutter/material.dart';

import '../theme/theme.dart';

enum EdsButtonVariant { primary, secondary, destructive, text }

/// The single button component. Use the named constructors.
class EdsButton extends StatelessWidget {
  const EdsButton.primary({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.expand = true,
    this.icon,
  }) : variant = EdsButtonVariant.primary;

  /// White, hairline-bordered, Ink label. Used for "Cancel",
  /// "Create an account", "Sign out".
  const EdsButton.secondary({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.expand = true,
    this.icon,
  }) : variant = EdsButtonVariant.secondary;

  /// Dark secondary button (Ink fill, White label). There is no red;
  /// destructive actions are distinguished by wording and confirmation.
  const EdsButton.destructive({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.expand = true,
    this.icon,
  }) : variant = EdsButtonVariant.destructive;

  /// Inline Ink link, e.g. "Forgot password?".
  const EdsButton.text({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.expand = false,
    this.icon,
  }) : variant = EdsButtonVariant.text;

  final String label;
  final VoidCallback? onPressed;
  final EdsButtonVariant variant;
  final bool isLoading;
  final bool expand;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    if (variant == EdsButtonVariant.text) {
      return InkWell(
        onTap: onPressed,
        borderRadius: AppRadius.smAll,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
          child: Row(
            mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
            children: [
              Text(label, style: AppTextStyles.link),
              if (icon != null) ...[
                const SizedBox(width: AppSpacing.xs),
                Icon(icon, size: AppSizes.iconSm, color: AppColors.ink),
              ],
            ],
          ),
        ),
      );
    }

    // Primary takes Crimson, pressed and disabled colors from the theme.
    final foreground = variant == EdsButtonVariant.secondary
        ? AppColors.ink
        : AppColors.white;
    final ButtonStyle? style = switch (variant) {
      EdsButtonVariant.primary => null,
      EdsButtonVariant.secondary => OutlinedButton.styleFrom(
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.ink,
        disabledForegroundColor: AppColors.gray,
        side: BorderSide(color: AppColors.border),
      ),
      EdsButtonVariant.destructive => FilledButton.styleFrom(
        backgroundColor: AppColors.ink,
        foregroundColor: AppColors.white,
        disabledBackgroundColor: AppColors.skeleton,
        disabledForegroundColor: AppColors.gray,
      ),
      EdsButtonVariant.text => throw StateError('unreachable'),
    };

    final child = isLoading
        ? SizedBox.square(
            dimension: 20,
            child: CircularProgressIndicator(strokeWidth: 2, color: foreground),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, size: AppSizes.iconSm),
                const SizedBox(width: AppSpacing.sm),
              ],
              Flexible(child: Text(label, overflow: TextOverflow.ellipsis)),
            ],
          );

    // Loading keeps the button's colors (a disabled button would turn
    // gray); taps are ignored until it finishes.
    return SizedBox(
      width: expand ? double.infinity : null,
      height: AppSizes.buttonHeight,
      child: IgnorePointer(
        ignoring: isLoading,
        child: FilledButton(
          onPressed: isLoading && onPressed == null ? () {} : onPressed,
          style: style,
          child: child,
        ),
      ),
    );
  }
}

/// Vertically stacked buttons with standard spacing (e.g. Confirm + Cancel).
class EdsButtonStack extends StatelessWidget {
  const EdsButtonStack({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < children.length; i++) ...[
          if (i > 0) AppSpacing.gapMd,
          children[i],
        ],
      ],
    );
  }
}
