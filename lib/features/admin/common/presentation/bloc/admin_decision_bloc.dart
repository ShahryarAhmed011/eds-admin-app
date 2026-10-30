import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'admin_decision_event.dart';
part 'admin_decision_state.dart';

/// UI state for [AdminDecisionSheet]: selected option + reason text.
///
/// [suggestedReasons] holds an optional prefilled reason per option. When the
/// admin switches options and has not edited the reason yet, the reason is
/// replaced with the newly selected option's suggestion.
class AdminDecisionBloc extends Bloc<AdminDecisionEvent, AdminDecisionState> {
  AdminDecisionBloc({
    required List<String?> suggestedReasons,
    int? initialIndex,
    String? initialReason,
  }) : _suggestedReasons = suggestedReasons,
       super(
         AdminDecisionState(
           selectedIndex: initialIndex,
           reason:
               initialReason ??
               (initialIndex == null ? null : suggestedReasons[initialIndex]) ??
               '',
         ),
       ) {
    on<AdminDecisionOptionSelected>(_onOptionSelected);
    on<AdminDecisionReasonChanged>(_onReasonChanged);
  }

  final List<String?> _suggestedReasons;

  void _onOptionSelected(
    AdminDecisionOptionSelected event,
    Emitter<AdminDecisionState> emit,
  ) {
    final previous = state.selectedIndex;
    final previousSuggestion = previous == null
        ? null
        : _suggestedReasons[previous];
    final untouched =
        state.reason.trim().isEmpty || state.reason == previousSuggestion;
    final suggestion = _suggestedReasons[event.index];
    emit(
      state.copyWith(
        selectedIndex: event.index,
        reason: untouched && suggestion != null ? suggestion : state.reason,
      ),
    );
  }

  void _onReasonChanged(
    AdminDecisionReasonChanged event,
    Emitter<AdminDecisionState> emit,
  ) => emit(state.copyWith(reason: event.reason));
}
