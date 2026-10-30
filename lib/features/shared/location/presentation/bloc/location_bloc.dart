import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/core.dart';
import '../../domain/entities/location_level.dart';
import '../../domain/entities/location_option.dart';
import '../../domain/entities/location_step.dart';
import '../../domain/usecase/detect_current_location.dart';
import '../../domain/usecase/get_location_step.dart';
import '../../domain/usecase/request_availability_updates.dart';
import '../../domain/usecase/select_location.dart';

part 'location_event.dart';
part 'location_state.dart';

/// Drives the delivery location drill-down: one level at a time, all on
/// the same screen.
class LocationBloc extends Bloc<LocationEvent, LocationState> {
  LocationBloc(
    this._getStep,
    this._select,
    this._detectCurrent,
    this._requestUpdates,
  ) : super(const LocationLoading()) {
    on<LocationStarted>(_onStarted);
    on<LocationSearchChanged>(_onSearchChanged);
    on<LocationOptionTapped>(_onOptionTapped);
    on<LocationContinuePressed>(_onContinuePressed);
    on<LocationUseMyLocationPressed>(_onUseMyLocation);
    on<LocationNotifyPhoneChanged>(_onPhoneChanged);
    on<LocationNotifyRequested>(_onNotifyRequested);
    on<LocationLevelRequested>(_onLevelRequested);
  }

  final GetLocationStep _getStep;
  final SelectLocation _select;
  final DetectCurrentLocation _detectCurrent;
  final RequestAvailabilityUpdates _requestUpdates;

  Future<void> _onStarted(
    LocationStarted event,
    Emitter<LocationState> emit,
  ) async {
    emit(const LocationLoading());
    try {
      final step = await _getStep(event.level);
      emit(LocationReady(step: step, notifyPhone: step.notifyPhone ?? ''));
    } catch (e) {
      emit(LocationFailure(errorMessage(e), reference: errorReference(e)));
    }
  }

  void _onSearchChanged(
    LocationSearchChanged event,
    Emitter<LocationState> emit,
  ) {
    final current = state;
    if (current is LocationReady) emit(current.copyWith(query: event.query));
  }

  void _onPhoneChanged(
    LocationNotifyPhoneChanged event,
    Emitter<LocationState> emit,
  ) {
    final current = state;
    if (current is LocationReady) {
      emit(current.copyWith(notifyPhone: event.phone));
    }
  }

  Future<void> _onOptionTapped(
    LocationOptionTapped event,
    Emitter<LocationState> emit,
  ) async {
    final current = state;
    if (current is! LocationReady) return;
    await _choose(current, event.option, emit);
  }

  Future<void> _onContinuePressed(
    LocationContinuePressed event,
    Emitter<LocationState> emit,
  ) async {
    final current = state;
    if (current is! LocationReady) return;
    final option = current.step.selectedOption;
    if (option != null) await _choose(current, option, emit);
  }

  Future<void> _onUseMyLocation(
    LocationUseMyLocationPressed event,
    Emitter<LocationState> emit,
  ) async {
    final current = state;
    if (current is! LocationReady) return;
    emit(current.copyWith(isBusy: true));
    try {
      final id = await _detectCurrent(current.step.level);
      final option = current.step.options.where((o) => o.id == id).firstOrNull;
      if (option == null) {
        emit(current);
      } else {
        await _choose(current, option, emit);
      }
    } catch (e) {
      emit(LocationFailure(errorMessage(e), reference: errorReference(e)));
    }
  }

  Future<void> _onNotifyRequested(
    LocationNotifyRequested event,
    Emitter<LocationState> emit,
  ) async {
    final current = state;
    if (current is! LocationReady || current.notifyPhone.isEmpty) return;
    emit(current.copyWith(isBusy: true));
    try {
      await _requestUpdates(current.notifyPhone);
      _emitOnce(emit, current, finished: LocationFinish.notified);
    } catch (e) {
      emit(LocationFailure(errorMessage(e), reference: errorReference(e)));
    }
  }

  void _onLevelRequested(
    LocationLevelRequested event,
    Emitter<LocationState> emit,
  ) {
    final current = state;
    if (current is LocationReady) {
      _emitOnce(emit, current, openLevel: event.level);
    }
  }

  /// Saves [option] and decides where the drill-down goes next.
  Future<void> _choose(
    LocationReady current,
    LocationOption option,
    Emitter<LocationState> emit,
  ) async {
    final level = current.step.level;
    try {
      await _select(SelectLocationParams(level: level, optionId: option.id));
    } catch (e) {
      emit(LocationFailure(errorMessage(e), reference: errorReference(e)));
      return;
    }
    final updated = current.copyWith(
      step: current.step.copyWith(selectedId: option.id),
    );
    switch (level) {
      case LocationLevel.area when option.isUnserved:
        _emitOnce(emit, updated, openLevel: LocationLevel.notServed);
      case LocationLevel.notServed when option.isUnserved:
        emit(updated);
      case LocationLevel.area || LocationLevel.notServed:
        _emitOnce(emit, updated, finished: LocationFinish.served);
      default:
        _emitOnce(emit, updated, openLevel: level.next);
    }
  }

  /// Emits a one-shot navigation request, then clears it.
  void _emitOnce(
    Emitter<LocationState> emit,
    LocationReady current, {
    LocationLevel? openLevel,
    LocationFinish? finished,
  }) {
    emit(
      current.copyWith(isBusy: false, openLevel: openLevel, finished: finished),
    );
    emit(current.copyWith(isBusy: false));
  }
}
