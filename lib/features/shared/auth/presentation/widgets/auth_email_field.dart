import 'package:flutter/material.dart';

import '../../../../../core/core.dart';
import 'auth_focus_theme.dart';

/// Email input in the style of [AuthPhoneField]: no label, a mail icon and
/// the Crimson focus border.
class AuthEmailField extends StatelessWidget {
  const AuthEmailField({
    super.key,
    required this.initialValue,
    required this.onChanged,
    this.errorText,
    this.textInputAction = TextInputAction.next,
  });

  final String initialValue;
  final ValueChanged<String> onChanged;
  final String? errorText;
  final TextInputAction textInputAction;

  @override
  Widget build(BuildContext context) {
    return AuthFocusTheme(
      child: EdsTextField(
        hint: 'Email address',
        errorText: errorText,
        initialValue: initialValue,
        keyboardType: TextInputType.emailAddress,
        textInputAction: textInputAction,
        prefix: const Icon(Icons.mail_outline),
        onChanged: onChanged,
      ),
    );
  }
}
