import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/theme.dart';

/// Labelled text input matching the Figma form fields.
class EdsTextField extends StatelessWidget {
  const EdsTextField({
    super.key,
    this.label,
    this.hint,
    this.helper,
    this.errorText,
    this.controller,
    this.initialValue,
    this.onChanged,
    this.keyboardType,
    this.inputFormatters,
    this.obscureText = false,
    this.readOnly = false,
    this.enabled = true,
    this.maxLines = 1,
    this.minLines,
    this.prefix,
    this.suffix,
    this.onTap,
    this.textInputAction,
  }) : assert(controller == null || initialValue == null);

  final String? label;
  final String? hint;
  final String? helper;
  final String? errorText;
  final TextEditingController? controller;
  final String? initialValue;
  final ValueChanged<String>? onChanged;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final bool obscureText;
  final bool readOnly;

  /// False: greyed out and can't be focused (e.g. a verified number).
  final bool enabled;
  final int maxLines;
  final int? minLines;
  final Widget? prefix;
  final Widget? suffix;
  final VoidCallback? onTap;
  final TextInputAction? textInputAction;

  @override
  Widget build(BuildContext context) {
    return EdsFieldLabel(
      label: label,
      helper: helper,
      child: TextFormField(
        controller: controller,
        initialValue: initialValue,
        onChanged: onChanged,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        obscureText: obscureText,
        obscuringCharacter: '•',
        readOnly: readOnly,
        enabled: enabled,
        onTap: onTap,
        maxLines: obscureText ? 1 : maxLines,
        minLines: minLines,
        textInputAction: textInputAction,
        style: enabled
            ? AppTextStyles.bodyLarge
            : AppTextStyles.bodyLarge.copyWith(color: AppColors.gray),
        decoration: InputDecoration(
          hintText: hint,
          errorText: errorText,
          prefixIcon: prefix,
          suffixIcon: suffix,
        ),
      ),
    );
  }
}

/// Wraps any input with the standard label above and helper text below.
class EdsFieldLabel extends StatelessWidget {
  const EdsFieldLabel({
    super.key,
    required this.child,
    this.label,
    this.helper,
  });

  final Widget child;
  final String? label;
  final String? helper;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (label != null) ...[
          Text(label!, style: AppTextStyles.label),
          AppSpacing.gapSm,
        ],
        child,
        if (helper != null) ...[
          AppSpacing.gapSm,
          Text(helper!, style: AppTextStyles.caption),
        ],
      ],
    );
  }
}

/// Labelled dropdown in the same style as [EdsTextField].
class EdsDropdownField<T> extends StatelessWidget {
  const EdsDropdownField({
    super.key,
    required this.items,
    required this.value,
    required this.onChanged,
    required this.itemLabel,
    this.label,
    this.helper,
  });

  final List<T> items;
  final T? value;
  final ValueChanged<T?> onChanged;
  final String Function(T) itemLabel;
  final String? label;
  final String? helper;

  @override
  Widget build(BuildContext context) {
    return EdsFieldLabel(
      label: label,
      helper: helper,
      child: DropdownButtonFormField<T>(
        initialValue: value,
        onChanged: onChanged,
        isExpanded: true,
        style: AppTextStyles.bodyLarge,
        icon: const Icon(Icons.keyboard_arrow_down, color: AppColors.ink),
        borderRadius: AppRadius.mdAll,
        dropdownColor: AppColors.white,
        items: [
          for (final item in items)
            DropdownMenuItem(value: item, child: Text(itemLabel(item))),
        ],
      ),
    );
  }
}

/// Rounded search input with a leading search icon.
class EdsSearchField extends StatelessWidget {
  const EdsSearchField({
    super.key,
    required this.hint,
    this.controller,
    this.onChanged,
    this.onTap,
    this.readOnly = false,
  });

  final String hint;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onTap;
  final bool readOnly;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      onTap: onTap,
      readOnly: readOnly,
      style: AppTextStyles.bodyLarge,
      textInputAction: TextInputAction.search,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: const Icon(Icons.search, color: AppColors.gray),
      ),
    );
  }
}
