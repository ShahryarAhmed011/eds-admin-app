import 'package:flutter/material.dart';

import '../theme/theme.dart';

/// Radio-style option row used in decision sheets.
class EdsRadioOption extends StatelessWidget {
  const EdsRadioOption({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AppColors.primaryTint : AppColors.white,
      borderRadius: AppRadius.mdAll,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.mdAll,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: 14,
          ),
          child: Row(
            children: [
              Icon(
                selected ? Icons.radio_button_checked : Icons.radio_button_off,
                color: selected ? AppColors.crimson : AppColors.gray,
                size: 20,
              ),
              AppSpacing.gapMd,
              Expanded(
                child: Text(
                  label,
                  style: AppTextStyles.bodyLarge.copyWith(
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Group of [EdsRadioOption]s with standard spacing.
class EdsRadioGroup extends StatelessWidget {
  const EdsRadioGroup({
    super.key,
    required this.options,
    required this.selectedIndex,
    required this.onChanged,
  });

  final List<String> options;
  final int? selectedIndex;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var i = 0; i < options.length; i++) ...[
          if (i > 0) AppSpacing.gapSm,
          EdsRadioOption(
            label: options[i],
            selected: i == selectedIndex,
            onTap: () => onChanged(i),
          ),
        ],
      ],
    );
  }
}

/// Large selectable card with avatar, used for the role picker.
class EdsSelectableCard extends StatelessWidget {
  const EdsSelectableCard({
    super.key,
    required this.child,
    required this.selected,
    required this.onTap,
  });

  final Widget child;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AppColors.primaryTint : AppColors.white,
      shape: RoundedRectangleBorder(
        borderRadius: AppRadius.mdAll,
        side: BorderSide(
          color: selected ? AppColors.crimson : AppColors.border,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(onTap: onTap, child: child),
    );
  }
}

/// Square checkbox: Gray outline at rest, Crimson when checked.
class EdsCheckbox extends StatelessWidget {
  const EdsCheckbox({super.key, required this.value, this.onChanged});

  final bool value;
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) {
    return Checkbox(
      value: value,
      onChanged: onChanged == null ? null : (v) => onChanged!(v ?? false),
      activeColor: AppColors.crimson,
      checkColor: AppColors.white,
      side: const BorderSide(color: AppColors.gray, width: 1.5),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(3)),
      ),
    );
  }
}
