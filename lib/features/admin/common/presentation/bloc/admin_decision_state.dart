part of 'admin_decision_bloc.dart';

final class AdminDecisionState extends Equatable {
  const AdminDecisionState({required this.selectedIndex, required this.reason});

  final int? selectedIndex;
  final String reason;

  /// An option is chosen and a non-empty reason is given.
  bool get canConfirm => selectedIndex != null && reason.trim().isNotEmpty;

  AdminDecisionState copyWith({int? selectedIndex, String? reason}) =>
      AdminDecisionState(
        selectedIndex: selectedIndex ?? this.selectedIndex,
        reason: reason ?? this.reason,
      );

  @override
  List<Object?> get props => [selectedIndex, reason];
}
