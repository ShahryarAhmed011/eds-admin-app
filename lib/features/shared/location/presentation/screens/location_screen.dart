import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/core.dart';
import '../../../../../core/di/injection.dart';
import '../../domain/entities/location_level.dart';
import '../bloc/location_bloc.dart';
import '../widgets/location_step_sheet.dart';
import '../widgets/location_summary_card.dart';

/// "Delivery location": the whole country → area drill-down on one route.
///
/// Open it with `context.push<bool>(AppRoutes.locationCountry)`. It pops
/// `true` once a served area is chosen (the app's current location has
/// moved), `false` when the user asked to be notified about an unserved
/// area, and null when they just backed out.
class LocationScreen extends StatelessWidget {
  const LocationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          sl<LocationBloc>()..add(const LocationStarted(LocationLevel.country)),
      child: const _LocationView(),
    );
  }
}

class _LocationView extends StatefulWidget {
  const _LocationView();

  @override
  State<_LocationView> createState() => _LocationViewState();
}

class _LocationViewState extends State<_LocationView> {
  LocationLevel _level = LocationLevel.country;

  /// Identifies the sheet currently shown, so a sheet closed by code
  /// isn't mistaken for the one opened after it.
  int _sheetId = 0;
  bool _sheetOpen = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _openSheet(_level);
    });
  }

  Future<void> _openSheet(LocationLevel level) async {
    final id = ++_sheetId;
    _level = level;
    _sheetOpen = true;
    await showLocationStepSheet(context, level);
    if (id == _sheetId) _sheetOpen = false;
  }

  void _closeSheet() {
    if (_sheetOpen) Navigator.of(context).pop();
    _sheetOpen = false;
  }

  void _onNavigation(BuildContext context, LocationReady state) {
    if (state.openLevel case final level?) {
      _closeSheet();
      context.read<LocationBloc>().add(LocationStarted(level));
      _openSheet(level);
      return;
    }
    _closeSheet();
    if (state.finished == LocationFinish.notified) {
      EdsToast.of(context).show(
        'We’ll text ${state.notifyPhone} when '
        '${state.step.unservedAreaName ?? 'your area'} opens.',
        kind: EdsToastKind.success,
      );
    }
    final served = state.finished == LocationFinish.served;
    if (context.canPop()) {
      context.pop(served);
    } else {
      context.go(sl<AuthSession>().role?.homeRoute ?? AppRoutes.customerHome);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<LocationBloc, LocationState>(
      listenWhen: (_, current) =>
          current is LocationReady &&
          (current.openLevel != null || current.finished != null),
      listener: (context, state) =>
          _onNavigation(context, state as LocationReady),
      child: EdsScaffold(
        title: 'Delivery location',
        bottomAction: EdsButton.primary(
          label: 'Change location',
          onPressed: () => _openSheet(_level),
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Where should we deliver?', style: AppTextStyles.headline),
            AppSpacing.gapMd,
            Text(
              'Find neighbourhood shops within 1–3 km.',
              style: AppTextStyles.bodyLarge.copyWith(color: AppColors.gray),
            ),
            AppSpacing.gapXl,
            BlocBuilder<LocationBloc, LocationState>(
              builder: (context, state) => switch (state) {
                LocationLoading() => const EdsLoadingView(),
                LocationFailure(:final message, :final reference) =>
                  EdsErrorView(
                    message: message,
                    reference: reference,
                    onRetry: () => context.read<LocationBloc>().add(
                      LocationStarted(_level),
                    ),
                  ),
                LocationReady(:final step) => LocationSummaryCard(
                  selection: step.selection,
                  onLevelTap: (level) => context.read<LocationBloc>().add(
                    LocationLevelRequested(level),
                  ),
                ),
              },
            ),
          ],
        ),
      ),
    );
  }
}
