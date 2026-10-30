import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/core.dart';
import '../auth/presentation/widgets/auth_focus_theme.dart';

/// Bottom sheets that edit one value in place: the field, then Save, which
/// stays off until the value is valid and differs from what's there. Each
/// closes itself before handing the value on, so the screen behind shows
/// the save. Fields carry the Crimson focus of the sign-in forms.

/// One text field; [minLength] 0 makes it optional (an empty result means
/// "clear"). A multi-line field holds at most [maxLines] lines.
Future<void> showTextFieldSheet(
  BuildContext context, {
  required String title,
  String? subtitle,
  required String label,
  String? hint,
  required String initial,
  int minLength = 0,
  int maxLines = 1,
  TextInputType? keyboardType,
  required ValueChanged<String> onSave,
}) => showEdsBottomSheet<void>(
  context: context,
  title: title,
  subtitle: subtitle,
  builder: (sheet) => _TextForm(
    label: label,
    hint: hint,
    initial: initial,
    minLength: minLength,
    maxLines: maxLines,
    keyboardType: keyboardType,
    onSave: closingSheet(sheet, onSave),
  ),
);

/// A single whole number between [min] and [max].
Future<void> showNumberFieldSheet(
  BuildContext context, {
  required String title,
  String? subtitle,
  required String label,
  required int? initial,
  required int min,
  required int max,
  required ValueChanged<int> onSave,
}) => showEdsBottomSheet<void>(
  context: context,
  title: title,
  subtitle: subtitle,
  builder: (sheet) => _NumberForm(
    label: label,
    initial: initial,
    min: min,
    max: max,
    onSave: closingSheet(sheet, onSave),
  ),
);

/// One of [options]; tapping a different one saves it straight away.
Future<void> showChoiceSheet<T>(
  BuildContext context, {
  required String title,
  String? subtitle,
  required List<T> options,
  required T? value,
  required String Function(T option) label,
  required ValueChanged<T> onSave,
}) => showEdsBottomSheet<void>(
  context: context,
  title: title,
  subtitle: subtitle,
  builder: (sheet) => _ChoiceList<T>(
    options: options,
    value: value,
    label: label,
    onPick: closingSheet(sheet, onSave),
  ),
);

/// Wraps [onSave] to close [sheet] first, so the screen behind shows the
/// save.
ValueChanged<T> closingSheet<T>(BuildContext sheet, ValueChanged<T> onSave) =>
    (value) {
      Navigator.of(sheet).pop();
      onSave(value);
    };

/// Sheet body for a custom form: the fields (with the Crimson focus of the
/// sign-in fields), then Save; lifts above the keyboard.
class FieldSheetForm extends StatelessWidget {
  const FieldSheetForm({
    super.key,
    required this.valid,
    required this.onSave,
    required this.children,
  });

  final bool valid;
  final VoidCallback onSave;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.only(
        top: AppSpacing.md,
        bottom: MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: AuthFocusTheme(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ...children,
            AppSpacing.gapXl,
            EdsButton.primary(label: 'Save', onPressed: valid ? onSave : null),
          ],
        ),
      ),
    );
  }
}

// ─── Forms ──────────────────────────────────────────────────────────────

class _TextForm extends StatefulWidget {
  const _TextForm({
    required this.label,
    required this.initial,
    required this.onSave,
    this.hint,
    this.minLength = 0,
    this.maxLines = 1,
    this.keyboardType,
  });

  final String label;
  final String? hint;
  final String initial;
  final int minLength;
  final int maxLines;
  final TextInputType? keyboardType;
  final ValueChanged<String> onSave;

  @override
  State<_TextForm> createState() => _TextFormState();
}

class _TextFormState extends State<_TextForm> {
  late String _text = widget.initial;

  bool get _valid =>
      _text.trim().length >= widget.minLength &&
      _text.trim() != widget.initial.trim();

  @override
  Widget build(BuildContext context) {
    final multiline = widget.maxLines > 1;
    return LayoutBuilder(
      builder: (context, constraints) => FieldSheetForm(
        valid: _valid,
        onSave: () => widget.onSave(_text.trim()),
        children: [
          EdsTextField(
            label: widget.label,
            hint: widget.hint,
            initialValue: _text,
            maxLines: widget.maxLines,
            minLines: multiline ? widget.maxLines : null,
            keyboardType:
                widget.keyboardType ??
                (multiline ? TextInputType.multiline : null),
            inputFormatters: multiline
                ? [
                    _MaxLines(
                      widget.maxLines,
                      // The field's text area: its width less the input
                      // padding and the focused border.
                      width: constraints.maxWidth - 2 * AppSpacing.md - 3,
                      textScaler: MediaQuery.textScalerOf(context),
                      textDirection: Directionality.of(context),
                    ),
                  ]
                : null,
            textInputAction: multiline
                ? TextInputAction.newline
                : TextInputAction.done,
            onChanged: (value) => setState(() => _text = value),
          ),
        ],
      ),
    );
  }
}

/// Refuses an edit that would wrap or break past [maxLines] in a text area
/// [width] wide, so the editor holds exactly that many lines and never
/// scrolls.
class _MaxLines extends TextInputFormatter {
  const _MaxLines(
    this.maxLines, {
    required this.width,
    required this.textScaler,
    required this.textDirection,
  });

  final int maxLines;
  final double width;
  final TextScaler textScaler;
  final TextDirection textDirection;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final painter = TextPainter(
      text: TextSpan(text: newValue.text, style: AppTextStyles.bodyLarge),
      textDirection: textDirection,
      textScaler: textScaler,
    )..layout(maxWidth: width);
    final lines = painter.computeLineMetrics().length;
    painter.dispose();
    return lines > maxLines ? oldValue : newValue;
  }
}

class _NumberForm extends StatefulWidget {
  const _NumberForm({
    required this.label,
    required this.initial,
    required this.min,
    required this.max,
    required this.onSave,
  });

  final String label;
  final int? initial;
  final int min;
  final int max;
  final ValueChanged<int> onSave;

  @override
  State<_NumberForm> createState() => _NumberFormState();
}

class _NumberFormState extends State<_NumberForm> {
  late String _text = widget.initial?.toString() ?? '';

  int? get _value {
    final value = int.tryParse(_text.trim());
    if (value == null || value < widget.min || value > widget.max) return null;
    return value;
  }

  @override
  Widget build(BuildContext context) {
    return FieldSheetForm(
      valid: _value != null && _value != widget.initial,
      onSave: () => widget.onSave(_value!),
      children: [
        EdsTextField(
          label: widget.label,
          initialValue: _text,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          textInputAction: TextInputAction.done,
          helper: '${widget.min} – ${widget.max}',
          onChanged: (value) => setState(() => _text = value),
        ),
      ],
    );
  }
}

/// The options as rows on one card; the current one carries a tick.
class _ChoiceList<T> extends StatelessWidget {
  const _ChoiceList({
    required this.options,
    required this.value,
    required this.label,
    required this.onPick,
  });

  final List<T> options;
  final T? value;
  final String Function(T option) label;
  final ValueChanged<T> onPick;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        top: AppSpacing.md,
        bottom: MediaQuery.paddingOf(context).bottom,
      ),
      child: EdsSettingsSection(
        children: [
          for (final option in options)
            InkWell(
              onTap: option == value ? null : () => onPick(option),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.md,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        label(option),
                        style: AppTextStyles.itemTitle,
                      ),
                    ),
                    if (option == value)
                      const Icon(
                        Icons.check_rounded,
                        size: 20,
                        color: AppColors.crimson,
                      ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
