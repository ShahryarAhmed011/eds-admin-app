part of 'admin_areas_bloc.dart';

sealed class AdminAreasEvent extends Equatable {
  const AdminAreasEvent();

  @override
  List<Object?> get props => [];
}

final class AdminAreasRequested extends AdminAreasEvent {
  const AdminAreasRequested();
}

final class AdminAreasSearchChanged extends AdminAreasEvent {
  const AdminAreasSearchChanged(this.query);

  final String query;

  @override
  List<Object?> get props => [query];
}

/// Turn an area on or off. Turning off is confirmed with a reason first.
final class AdminAreaServiceabilityChanged extends AdminAreasEvent {
  const AdminAreaServiceabilityChanged({
    required this.areaId,
    required this.serviceable,
    required this.reason,
  });

  final String areaId;
  final bool serviceable;
  final String reason;

  @override
  List<Object?> get props => [areaId, serviceable, reason];
}
