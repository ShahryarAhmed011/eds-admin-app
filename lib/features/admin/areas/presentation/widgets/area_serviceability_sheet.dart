import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/core.dart';
import '../../../common/presentation/bloc/admin_decision_bloc.dart';
import '../../domain/entities/service_area.dart';
import 'service_area_labels.dart';

const _suggestedReason =
    'Temporary rider coverage gap. Review service availability tomorrow.';

/// Confirms stopping service in [area]. Resolves with the reason, or `null`
/// when the admin keeps the area serviceable.
Future<String?> showAreaServiceabilitySheet(
  BuildContext context, {
  required ServiceAreaScope scope,
  required ServiceArea area,
}) {
  return showEdsBottomSheet<String>(
    context: context,
    title: 'Stop service in ${area.name}?',
    subtitle: '${scope.city} · ${scope.town} · ${area.name}',
    builder: (sheetContext) => AreaServiceabilitySheet(
      area: area,
      onConfirm: (reason) => Navigator.of(sheetContext).pop(reason),
      onCancel: () => Navigator.of(sheetContext).pop(),
    ),
  );
}

/// Body of the "Stop service" confirmation: impact banner, required reason,
/// audit note, confirm + keep buttons. Reason state reuses the shared
/// [AdminDecisionBloc] with a single implicit option.
class AreaServiceabilitySheet extends StatelessWidget {
  const AreaServiceabilitySheet({
    super.key,
    required this.area,
    required this.onConfirm,
    required this.onCancel,
  });

  final ServiceArea area;
  final ValueChanged<String> onConfirm;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AdminDecisionBloc(
        suggestedReasons: const [_suggestedReason],
        initialIndex: 0,
      ),
      child: _AreaServiceabilityView(sheet: this),
    );
  }
}

class _AreaServiceabilityView extends StatefulWidget {
  const _AreaServiceabilityView({required this.sheet});

  final AreaServiceabilitySheet sheet;

  @override
  State<_AreaServiceabilityView> createState() =>
      _AreaServiceabilityViewState();
}

class _AreaServiceabilityViewState extends State<_AreaServiceabilityView> {
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
    return BlocBuilder<AdminDecisionBloc, AdminDecisionState>(
      builder: (context, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            EdsBanner(
              title: sheet.area.impactLabel ?? 'Customer discovery stops',
              message:
                  'Customers in this area will see Not served yet. Shop data '
                  'remains saved and no accounts are closed.',
              tone: EdsTone.warning,
            ),
            AppSpacing.gapLg,
            EdsTextField(
              label: 'Reason · required',
              controller: _reason,
              minLines: 2,
              maxLines: 4,
              onChanged: (v) => context.read<AdminDecisionBloc>().add(
                AdminDecisionReasonChanged(v),
              ),
            ),
            AppSpacing.gapMd,
            Text(
              'The change takes effect immediately and is saved in the audit '
              'log.',
              style: AppTextStyles.caption,
            ),
            AppSpacing.gapLg,
            EdsButtonStack(
              children: [
                EdsButton.destructive(
                  label: 'Confirm · Mark not served',
                  onPressed: state.canConfirm
                      ? () => sheet.onConfirm(state.reason.trim())
                      : null,
                ),
                EdsButton.secondary(
                  label: 'Keep serviceable',
                  onPressed: sheet.onCancel,
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}
