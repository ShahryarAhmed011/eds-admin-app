import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/core.dart';
import '../../domain/entities/location_level.dart';
import '../../domain/entities/location_option.dart';
import '../bloc/location_bloc.dart';
import 'location_level_ui.dart';

/// Opens the picker sheet for [level], sharing the caller's [LocationBloc].
Future<void> showLocationStepSheet(BuildContext context, LocationLevel level) {
  final bloc = context.read<LocationBloc>();
  return showEdsBottomSheet<void>(
    context: context,
    title: level.sheetTitle,
    builder: (_) => BlocProvider.value(
      value: bloc,
      child: LocationStepSheet(level: level),
    ),
  );
}

/// Body of every location step: step chip, breadcrumb, search or
/// not-served notice, option list and the step's actions.
class LocationStepSheet extends StatelessWidget {
  const LocationStepSheet({super.key, required this.level});

  final LocationLevel level;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LocationBloc, LocationState>(
      builder: (context, state) => switch (state) {
        LocationLoading() => const EdsLoadingView(),
        LocationFailure(:final message, :final reference) => EdsErrorView(
          message: message,
          reference: reference,
          onRetry: () =>
              context.read<LocationBloc>().add(LocationStarted(level)),
        ),
        LocationReady() => _StepContent(state),
      },
    );
  }
}

class _StepContent extends StatelessWidget {
  const _StepContent(this.state);

  final LocationReady state;

  @override
  Widget build(BuildContext context) {
    final step = state.step;
    final bloc = context.read<LocationBloc>();
    final notServed = step.level == LocationLevel.notServed;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            EdsBadge(
              'Step ${step.level.stepNumber} of ${LocationLevel.totalSteps}',
            ),
            const Spacer(),
            Text('Location setup', style: AppTextStyles.bodySecondary),
          ],
        ),
        AppSpacing.gapMd,
        Text(step.breadcrumb, style: AppTextStyles.bodySecondary),
        AppSpacing.gapMd,
        if (notServed) ...[
          EdsBanner(
            tone: EdsTone.warning,
            title: 'We’re not in ${step.unservedAreaName} yet',
            message:
                'Choose a served area to browse nearby shops. We’ll let you '
                'know when your neighbourhood opens.',
          ),
          AppSpacing.gapLg,
          EdsTextField(
            label: 'Mobile for availability updates',
            initialValue: state.notifyPhone,
            keyboardType: TextInputType.phone,
            onChanged: (value) => bloc.add(LocationNotifyPhoneChanged(value)),
          ),
        ] else ...[
          EdsButton.secondary(
            label: 'Use my location',
            icon: Icons.my_location,
            isLoading: state.isBusy,
            onPressed: () => bloc.add(const LocationUseMyLocationPressed()),
          ),
          AppSpacing.gapMd,
          EdsSearchField(
            hint: step.level.searchHint,
            onChanged: (value) => bloc.add(LocationSearchChanged(value)),
          ),
        ],
        AppSpacing.gapSm,
        _OptionList(
          options: state.visibleOptions,
          selectedId: step.selectedId,
          emptyLabel: 'No ${step.level.label.toLowerCase()}s listed here yet',
          comingSoonLabel:
              step.level == LocationLevel.country && state.query.isEmpty
              ? 'More countries coming soon'
              : null,
          onTap: (option) => bloc.add(LocationOptionTapped(option)),
        ),
        AppSpacing.gapMd,
        Text(
          notServed
              ? 'No delivery promise applies outside served areas.'
              : 'Changing a parent location clears its dependent selections.',
          style: AppTextStyles.caption,
        ),
        AppSpacing.gapMd,
        if (notServed)
          EdsButtonStack(
            children: [
              EdsButton.secondary(
                label: 'Choose another area',
                onPressed: () =>
                    bloc.add(const LocationLevelRequested(LocationLevel.area)),
              ),
              EdsButton.primary(
                label: 'Notify me when available',
                isLoading: state.isBusy,
                onPressed: state.notifyPhone.isEmpty
                    ? null
                    : () => bloc.add(const LocationNotifyRequested()),
              ),
            ],
          )
        else
          EdsButton.primary(
            label: step.level.continueLabel,
            onPressed: step.selectedOption == null
                ? null
                : () => bloc.add(const LocationContinuePressed()),
          ),
      ],
    );
  }
}

class _OptionList extends StatelessWidget {
  const _OptionList({
    required this.options,
    required this.selectedId,
    required this.onTap,
    required this.emptyLabel,
    this.comingSoonLabel,
  });

  final List<LocationOption> options;
  final String? selectedId;
  final ValueChanged<LocationOption> onTap;
  final String emptyLabel;

  /// Non-selectable placeholder row shown after the options.
  final String? comingSoonLabel;

  @override
  Widget build(BuildContext context) {
    if (options.isEmpty && comingSoonLabel == null) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
        child: Text(emptyLabel, style: AppTextStyles.bodySecondary),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final option in options) ...[
          EdsListTile(
            title: option.displayName,
            titleStyle: AppTextStyles.itemTitleLarge,
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
            trailing: option.id == selectedId
                ? const Icon(
                    Icons.check_circle_outline,
                    color: AppColors.crimson,
                  )
                : null,
            showChevron: option.id != selectedId,
            onTap: () => onTap(option),
          ),
          const Divider(height: 1),
        ],
        if (comingSoonLabel case final label?) ...[
          EdsListTile(
            title: label,
            titleStyle: AppTextStyles.itemTitleLarge,
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
            showChevron: true,
          ),
          const Divider(height: 1),
        ],
      ],
    );
  }
}
