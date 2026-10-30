import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/core.dart';
import '../../../../../core/di/injection.dart';
import '../../domain/entities/service_area.dart';
import '../bloc/admin_areas_bloc.dart';
import '../widgets/area_serviceability_sheet.dart';
import '../widgets/service_area_labels.dart';

class AdminServiceableAreasScreen extends StatelessWidget {
  const AdminServiceableAreasScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<AdminAreasBloc>()..add(const AdminAreasRequested()),
      child: const _AdminServiceableAreasView(),
    );
  }
}

/// Asks for confirmation before turning [area] off; turning on is immediate.
Future<void> _changeServiceability(
  BuildContext context, {
  required ServiceAreaScope scope,
  required ServiceArea area,
  required bool serviceable,
}) async {
  final bloc = context.read<AdminAreasBloc>();
  if (serviceable) {
    bloc.add(
      AdminAreaServiceabilityChanged(
        areaId: area.id,
        serviceable: true,
        reason: 'Service enabled by admin.',
      ),
    );
    return;
  }
  final reason = await showAreaServiceabilitySheet(
    context,
    scope: scope,
    area: area,
  );
  if (reason == null) return;
  bloc.add(
    AdminAreaServiceabilityChanged(
      areaId: area.id,
      serviceable: false,
      reason: reason,
    ),
  );
}

class _AdminServiceableAreasView extends StatelessWidget {
  const _AdminServiceableAreasView();

  @override
  Widget build(BuildContext context) {
    return EdsScaffold(
      title: 'Serviceable areas',
      bottomNav: const EdsBottomNav(
        items: RoleNavs.admin,
        currentIndex: AdminTab.more,
      ),
      body: BlocConsumer<AdminAreasBloc, AdminAreasState>(
        listenWhen: (previous, current) =>
            current is AdminAreasLoaded &&
            (current.lastChanged != null || current.actionError != null),
        listener: (context, state) {
          final loaded = state as AdminAreasLoaded;
          final changed = loaded.lastChanged;
          if (loaded.actionError != null) {
            EdsToast.of(
              context,
            ).show(loaded.actionError!, kind: EdsToastKind.error);
            return;
          }
          if (changed != null) {
            EdsToast.of(context).show(
              '${changed.title} · Saved in the audit log',
              kind: EdsToastKind.success,
            );
          }
        },
        builder: (context, state) => switch (state) {
          AdminAreasLoading() => const EdsLoadingView(),
          AdminAreasFailure(:final message, :final reference) => EdsErrorView(
            message: message,
            reference: reference,
            onRetry: () =>
                context.read<AdminAreasBloc>().add(const AdminAreasRequested()),
          ),
          final AdminAreasLoaded loaded => _AreasContent(loaded),
        },
      ),
    );
  }
}

class _AreasContent extends StatelessWidget {
  const _AreasContent(this.state);

  final AdminAreasLoaded state;

  @override
  Widget build(BuildContext context) {
    final scope = state.scope;
    final areas = state.visibleAreas;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        EdsTextField(
          label: 'Location scope',
          initialValue: scope.label,
          readOnly: true,
        ),
        AppSpacing.gapLg,
        EdsSearchField(
          hint: 'Search town or area',
          onChanged: (q) =>
              context.read<AdminAreasBloc>().add(AdminAreasSearchChanged(q)),
        ),
        AppSpacing.gapXl,
        EdsSectionHeader(
          title:
              '${scope.town} · ${scope.servedCount} of ${scope.areas.length} '
              'areas served',
          subtitle: 'Changes control customer discovery',
        ),
        AppSpacing.gapLg,
        if (areas.isEmpty)
          EdsCard(
            child: Text(
              'No areas match your search.',
              style: AppTextStyles.bodySecondary,
            ),
          )
        else
          EdsGroupCard(
            children: [
              for (final area in areas)
                EdsListTile(
                  title: area.title,
                  titleStyle: AppTextStyles.itemTitleLarge,
                  subtitle: area.subtitle,
                  trailing: Switch(
                    value: area.isServiceable,
                    onChanged: state.updatingAreaId == area.id
                        ? null
                        : (value) => _changeServiceability(
                            context,
                            scope: scope,
                            area: area,
                            serviceable: value,
                          ),
                  ),
                ),
            ],
          ),
        AppSpacing.gapLg,
        const EdsBanner(
          title: 'Confirm consequential changes',
          message:
              'Turning an area off shows a Not served yet notice to customers '
              'in that area.',
          tone: EdsTone.warning,
        ),
      ],
    );
  }
}
