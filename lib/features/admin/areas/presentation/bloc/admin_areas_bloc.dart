import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/core.dart';
import '../../domain/entities/service_area.dart';
import '../../domain/usecase/get_serviceable_areas.dart';
import '../../domain/usecase/set_area_serviceability.dart';

part 'admin_areas_event.dart';
part 'admin_areas_state.dart';

class AdminAreasBloc extends Bloc<AdminAreasEvent, AdminAreasState> {
  AdminAreasBloc(this._getAreas, this._setServiceability)
    : super(const AdminAreasLoading()) {
    on<AdminAreasRequested>(_onRequested);
    on<AdminAreasSearchChanged>(_onSearchChanged);
    on<AdminAreaServiceabilityChanged>(_onServiceabilityChanged);
  }

  final GetServiceableAreas _getAreas;
  final SetAreaServiceability _setServiceability;

  Future<void> _onRequested(
    AdminAreasRequested event,
    Emitter<AdminAreasState> emit,
  ) async {
    emit(const AdminAreasLoading());
    try {
      emit(AdminAreasLoaded(scope: await _getAreas(const NoParams())));
    } catch (e) {
      emit(AdminAreasFailure(errorMessage(e), reference: errorReference(e)));
    }
  }

  void _onSearchChanged(
    AdminAreasSearchChanged event,
    Emitter<AdminAreasState> emit,
  ) {
    if (state case final AdminAreasLoaded s) {
      emit(s.copyWith(query: event.query, clearLastChange: true));
    }
  }

  Future<void> _onServiceabilityChanged(
    AdminAreaServiceabilityChanged event,
    Emitter<AdminAreasState> emit,
  ) async {
    final current = state;
    if (current is! AdminAreasLoaded) return;
    final area = current.scope.areas
        .where((a) => a.id == event.areaId)
        .firstOrNull;
    if (area == null) return;
    emit(current.copyWith(updatingAreaId: area.id, clearLastChange: true));
    try {
      final updated = await _setServiceability(
        AreaServiceabilityParams(
          area: area,
          serviceable: event.serviceable,
          reason: event.reason,
        ),
      );
      emit(
        AdminAreasLoaded(
          scope: current.scope.copyWithArea(updated),
          query: current.query,
          lastChanged: updated,
        ),
      );
    } catch (e) {
      // Keep the list as it was and surface the error.
      emit(
        AdminAreasLoaded(
          scope: current.scope,
          query: current.query,
          actionError: errorMessage(e),
        ),
      );
    }
  }
}
