import 'package:flutter/material.dart';

import '../../../../../core/core.dart';
import 'auth_focus_theme.dart';

/// Password input with an eye button to show or hide what's typed, and the
/// Crimson focus border of the other auth fields.
class AuthPasswordField extends StatefulWidget {
  const AuthPasswordField({
    super.key,
    required this.initialValue,
    required this.onChanged,
    this.label = 'Password',
    this.hint,
    this.textInputAction = TextInputAction.done,
  });

  final String initialValue;
  final ValueChanged<String> onChanged;

  /// Null hides the label.
  final String? label;
  final String? hint;
  final TextInputAction textInputAction;

  @override
  State<AuthPasswordField> createState() => _AuthPasswordFieldState();
}

class _AuthPasswordFieldState extends State<AuthPasswordField> {
  bool _obscured = true;

  @override
  Widget build(BuildContext context) {
    return AuthFocusTheme(
      child: EdsTextField(
        label: widget.label,
        hint: widget.hint,
        initialValue: widget.initialValue,
        obscureText: _obscured,
        keyboardType: TextInputType.visiblePassword,
        textInputAction: widget.textInputAction,
        prefix: const Icon(Icons.lock_outline),
        suffix: IconButton(
          tooltip: _obscured ? 'Show password' : 'Hide password',
          icon: Icon(
            _obscured
                ? Icons.visibility_outlined
                : Icons.visibility_off_outlined,
          ),
          onPressed: () => setState(() => _obscured = !_obscured),
        ),
        onChanged: widget.onChanged,
      ),
    );
  }
}
