import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../../core/core.dart';
import '../../../common/phone_number.dart';
import 'auth_focus_theme.dart';

/// Pakistani mobile number with a fixed Pakistan flag and `+92` prefix
/// (no country picker yet). Reports national digits (e.g. `3001234567`).
class AuthPhoneField extends StatelessWidget {
  const AuthPhoneField({
    super.key,
    required this.initialDigits,
    required this.onChanged,
    this.label = 'Mobile number',
    this.helper,
    this.errorText,
    this.textInputAction = TextInputAction.next,
  });

  final String initialDigits;
  final ValueChanged<String> onChanged;

  /// Null hides the label (e.g. the single field on sign in).
  final String? label;
  final String? helper;
  final String? errorText;
  final TextInputAction textInputAction;

  @override
  Widget build(BuildContext context) {
    return AuthFocusTheme(child: _field());
  }

  Widget _field() {
    return EdsTextField(
      label: label,
      hint: '300-1234567',
      helper: helper,
      errorText: errorText,
      initialValue: PhoneNumber.formatNational(initialDigits),
      keyboardType: TextInputType.phone,
      textInputAction: textInputAction,
      inputFormatters: const [_NationalNumberFormatter()],
      prefix: Padding(
        padding: const EdgeInsets.only(
          left: AppSpacing.lg,
          right: AppSpacing.sm,
        ),
        // prefixIcon doesn't center its child vertically.
        child: Center(
          widthFactor: 1,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Text emoji, so the flag needs no image asset.
              Text(PhoneNumber.countryFlag, style: AppTextStyles.bodyLarge),
              AppSpacing.gapSm,
              Text(PhoneNumber.countryCode, style: AppTextStyles.bodyLarge),
            ],
          ),
        ),
      ),
      onChanged: (value) => onChanged(PhoneNumber.nationalDigits(value)),
    );
  }
}

/// Keeps the field as "300-1234567" while typing: digits only, at most
/// [PhoneNumber.nationalLength], with a dash after the first three. Pasted
/// numbers lose their `+92` / leading `0`.
class _NationalNumberFormatter extends TextInputFormatter {
  const _NationalNumberFormatter();

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    var raw = newValue.text;
    var cursor = newValue.selection.end.clamp(0, raw.length);
    // Backspace on the dash alone would just re-add it; delete the digit
    // before it instead.
    final dash = oldValue.text.indexOf('-');
    if (dash > 0 &&
        raw.length == oldValue.text.length - 1 &&
        cursor == dash &&
        !raw.contains('-')) {
      raw = raw.substring(0, dash - 1) + raw.substring(dash);
      cursor = dash - 1;
    }
    var digits = PhoneNumber.nationalDigits(raw);
    if (digits.length > PhoneNumber.nationalLength) {
      digits = digits.substring(0, PhoneNumber.nationalLength);
    }
    final text = PhoneNumber.formatNational(digits);

    // Keep the caret after the same number of digits it followed; a paste
    // that dropped a prefix puts it at the end.
    var before = raw.substring(0, cursor).replaceAll(RegExp(r'\D'), '').length;
    if (raw.replaceAll(RegExp(r'\D'), '') != digits) before = digits.length;
    var offset = before > 3 ? before + 1 : before;
    if (offset > text.length) offset = text.length;

    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: offset),
    );
  }
}
