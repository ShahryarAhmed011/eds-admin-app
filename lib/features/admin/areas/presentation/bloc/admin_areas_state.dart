part of 'admin_areas_bloc.dart';

sealed class AdminAreasState extends Equatable {
  const AdminAreasState();

  @override
  List<Object?> get props => [];
}

final class AdminAreasLoading extends AdminAreasState {
  const AdminAreasLoading();
}

final class AdminAreasLoaded extends AdminAreasState {
  const AdminAreasLoaded({
    required this.scope,
    this.query = '',
    this.updatingAreaId,
    this.lastChanged,
    this.actionError,
  });

  final ServiceAreaScope scope;
  final String query;

  /// Area whose change is being saved.
  final String? updatingAreaId;

  /// Set right after a change is saved.
  final ServiceArea? lastChanged;

  /// Set right after a change failed to save.
  final String? actionError;

  List<ServiceArea> get visibleAreas {
    final q = query.trim().toLowerCase();
    return [
      for (final area in scope.areas)
        if (q.isEmpty || area.name.toLowerCase().contains(q)) area,
    ];
  }

  AdminAreasLoaded copyWith({
    String? query,
    String? updatingAreaId,
    bool clearLastChange = false,
  }) => AdminAreasLoaded(
    scope: scope,
    query: query ?? this.query,
    updatingAreaId: updatingAreaId ?? this.updatingAreaId,
    lastChanged: clearLastChange ? null : lastChanged,
  );

  @override
  List<Object?> get props => [
    scope,
    query,
    updatingAreaId,
    lastChanged,
    actionError,
  ];
}

final class AdminAreasFailure extends AdminAreasState {
  const AdminAreasFailure(this.message, {this.reference});

  final String message;
  final String? reference;

  @override
  List<Object?> get props => [message, reference];
}
