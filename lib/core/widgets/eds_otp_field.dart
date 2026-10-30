import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/theme.dart';

/// Row of single-digit boxes for one-time codes.
class EdsOtpField extends StatefulWidget {
  const EdsOtpField({
    super.key,
    this.length = 6,
    this.initialValue = '',
    this.hasError = false,
    this.enabled = true,
    this.autofocus = false,
    this.onChanged,
    this.onCompleted,
  });

  final int length;
  final String initialValue;
  final bool hasError;
  final bool enabled;

  /// Opens the keyboard as soon as the field appears.
  final bool autofocus;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onCompleted;

  @override
  State<EdsOtpField> createState() => _EdsOtpFieldState();
}

class _EdsOtpFieldState extends State<EdsOtpField> {
  late final TextEditingController _controller = TextEditingController(
    text: widget.initialValue,
  );
  // Rebuilds so the active box shows focus.
  late final FocusNode _focusNode = FocusNode()
    ..addListener(() => setState(() {}));

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _handleChanged(String value) {
    setState(() {});
    widget.onChanged?.call(value);
    if (value.length == widget.length) widget.onCompleted?.call(value);
  }

  @override
  Widget build(BuildContext context) {
    final code = _controller.text;
    return GestureDetector(
      onTap: widget.enabled ? _focusNode.requestFocus : null,
      child: Stack(
        children: [
          // Hidden input that drives the visible boxes.
          Opacity(
            opacity: 0,
            child: SizedBox(
              height: 1,
              child: TextField(
                controller: _controller,
                focusNode: _focusNode,
                enabled: widget.enabled,
                autofocus: widget.autofocus,
                autofillHints: const [AutofillHints.oneTimeCode],
                keyboardType: TextInputType.number,
                maxLength: widget.length,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                onChanged: _handleChanged,
              ),
            ),
          ),
          Row(
            children: [
              for (var i = 0; i < widget.length; i++) ...[
                if (i > 0) AppSpacing.gapSm,
                Expanded(
                  child: _OtpBox(
                    digit: i < code.length ? code[i] : '',
                    filled: i < code.length,
                    isActive:
                        widget.enabled &&
                        _focusNode.hasFocus &&
                        i == code.length,
                    hasError: widget.hasError,
                    enabled: widget.enabled,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _OtpBox extends StatelessWidget {
  const _OtpBox({
    required this.digit,
    required this.filled,
    required this.isActive,
    required this.hasError,
    required this.enabled,
  });

  final String digit;
  final bool filled;
  final bool isActive;
  final bool hasError;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    // The box being typed into is Crimson while focused, like a focused
    // text field. Errors are Ink (never red): every box gets a heavy Ink
    // border.
    final strong = hasError || isActive;
    final borderColor = hasError || filled
        ? AppColors.ink
        : isActive
        ? AppColors.crimson
        : AppColors.border;
    return AspectRatio(
      aspectRatio: 0.9,
      child: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: enabled ? AppColors.white : AppColors.sectionBackground,
          borderRadius: AppRadius.smAll,
          border: Border.all(color: borderColor, width: strong ? 1.5 : 1),
        ),
        child: Text(
          digit,
          style: AppTextStyles.headline.copyWith(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
