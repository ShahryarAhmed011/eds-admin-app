import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/core.dart';
import '../bloc/admin_decision_bloc.dart';

/// One radio choice in an [AdminDecisionSheet].
class AdminDecisionOption extends Equatable {
  const AdminDecisionOption({
    required this.label,
    required this.confirmLabel,
    this.destructive = false,
    this.suggestedReason,
  });

  /// Radio label, e.g. "Suspend account".
  final String label;

  /// Confirm button label while this option is selected,
  /// e.g. "Confirm suspension".
  final String confirmLabel;

  /// Render the confirm button as [EdsButton.destructive] (red).
  final bool destructive;

  /// Prefilled into the reason field when this option gets selected and the
  /// admin has not typed their own reason yet.
  final String? suggestedReason;

  @override
  List<Object?> get props => [
    label,
    confirmLabel,
    destructive,
    suggestedReason,
  ];
}

/// What the admin confirmed in an [AdminDecisionSheet].
class AdminDecisionResult extends Equatable {
  const AdminDecisionResult({required this.optionIndex, required this.reason});

  /// Index into the `options` list passed to the sheet.
  final int optionIndex;

  /// Trimmed, non-empty reason.
  final String reason;

  @override
  List<Object?> get props => [optionIndex, reason];
}

/// Opens the standard admin decision sheet (radio options, required reason,
/// audit-log note, confirm + cancel). Resolves with the decision, or `null`
/// when cancelled/dismissed.
Future<AdminDecisionResult?> showAdminDecisionSheet(
  BuildContext context, {
  required String title,
  String? subtitle,
  required List<AdminDecisionOption> options,
  int? initialIndex,
  String? initialReason,
  String reasonLabel = AdminDecisionSheet.defaultReasonLabel,
  String? reasonHint,
  String auditNote = AdminDecisionSheet.defaultAuditNote,
}) {
  return showEdsBottomSheet<AdminDecisionResult>(
    context: context,
    title: title,
    subtitle: subtitle,
    builder: (sheetContext) => AdminDecisionSheet(
      options: options,
      initialIndex: initialIndex,
      initialReason: initialReason,
      reasonLabel: reasonLabel,
      reasonHint: reasonHint,
      auditNote: auditNote,
      onConfirm: (result) => Navigator.of(sheetContext).pop(result),
      onCancel: () => Navigator.of(sheetContext).pop(),
    ),
  );
}

/// Body of an admin decision sheet. Title/subtitle are rendered by the
/// surrounding [EdsBottomSheet]; use [showAdminDecisionSheet] to open it.
class AdminDecisionSheet extends StatelessWidget {
  const AdminDecisionSheet({
    super.key,
    required this.options,
    required this.onConfirm,
    required this.onCancel,
    this.initialIndex,
    this.initialReason,
    this.reasonLabel = defaultReasonLabel,
    this.reasonHint,
    this.auditNote = defaultAuditNote,
  });

  static const defaultReasonLabel = 'Reason · required';
  static const defaultAuditNote =
      'This decision and reason will be saved in the audit log.';

  final List<AdminDecisionOption> options;
  final ValueChanged<AdminDecisionResult> onConfirm;
  final VoidCallback onCancel;
  final int? initialIndex;
  final String? initialReason;
  final String reasonLabel;
  final String? reasonHint;
  final String auditNote;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AdminDecisionBloc(
        suggestedReasons: [for (final o in options) o.suggestedReason],
        initialIndex: initialIndex,
        initialReason: initialReason,
      ),
      child: _AdminDecisionView(sheet: this),
    );
  }
}

class _AdminDecisionView extends StatefulWidget {
  const _AdminDecisionView({required this.sheet});

  final AdminDecisionSheet sheet;

  @override
  State<_AdminDecisionView> createState() => _AdminDecisionViewState();
}

class _AdminDecisionViewState extends State<_AdminDecisionView> {
  late final TextEditingController _reason;

  @override
  void initState() {
    super.initState();
    _reason = TextEditingController(
      text: context.read<AdminDecisionBloc>().state.reason,
    );
  }

  @override
  void dispose() {
    _reason.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sheet = widget.sheet;
    return BlocConsumer<AdminDecisionBloc, AdminDecisionState>(
      listenWhen: (_, current) => current.reason != _reason.text,
      listener: (_, state) => _reason.text = state.reason,
      builder: (context, state) {
        final bloc = context.read<AdminDecisionBloc>();
        final selected = state.selectedIndex == null
            ? null
            : sheet.options[state.selectedIndex!];
        final onConfirm = state.canConfirm
            ? () => sheet.onConfirm(
                AdminDecisionResult(
                  optionIndex: state.selectedIndex!,
                  reason: state.reason.trim(),
                ),
              )
            : null;
        final confirmLabel = selected?.confirmLabel ?? 'Confirm';

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            EdsRadioGroup(
              options: [for (final o in sheet.options) o.label],
              selectedIndex: state.selectedIndex,
              onChanged: (i) => bloc.add(AdminDecisionOptionSelected(i)),
            ),
            AppSpacing.gapLg,
            EdsTextField(
              label: sheet.reasonLabel,
              hint: sheet.reasonHint,
              controller: _reason,
              minLines: 2,
              maxLines: 4,
              onChanged: (v) => bloc.add(AdminDecisionReasonChanged(v)),
            ),
            AppSpacing.gapMd,
            Text(sheet.auditNote, style: AppTextStyles.caption),
            AppSpacing.gapLg,
            EdsButtonStack(
              children: [
                if (selected?.destructive ?? false)
                  EdsButton.destructive(
                    label: confirmLabel,
                    onPressed: onConfirm,
                  )
                else
                  EdsButton.primary(label: confirmLabel, onPressed: onConfirm),
                EdsButton.secondary(label: 'Cancel', onPressed: sheet.onCancel),
              ],
            ),
          ],
        );
      },
    );
  }
}
