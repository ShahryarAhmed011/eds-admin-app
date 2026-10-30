part of 'location_bloc.dart';

sealed class LocationEvent extends Equatable {
  const LocationEvent();

  @override
  List<Object?> get props => [];
}

final class LocationStarted extends LocationEvent {
  const LocationStarted(this.level);

  final LocationLevel level;

  @override
  List<Object?> get props => [level];
}

final class LocationSearchChanged extends LocationEvent {
  const LocationSearchChanged(this.query);

  final String query;

  @override
  List<Object?> get props => [query];
}

final class LocationOptionTapped extends LocationEvent {
  const LocationOptionTapped(this.option);

  final LocationOption option;

  @override
  List<Object?> get props => [option];
}

final class LocationContinuePressed extends LocationEvent {
  const LocationContinuePressed();
}

final class LocationUseMyLocationPressed extends LocationEvent {
  const LocationUseMyLocationPressed();
}

final class LocationNotifyPhoneChanged extends LocationEvent {
  const LocationNotifyPhoneChanged(this.phone);

  final String phone;

  @override
  List<Object?> get props => [phone];
}

final class LocationNotifyRequested extends LocationEvent {
  const LocationNotifyRequested();
}

/// Jump to a level (summary row tap, "Choose another area").
final class LocationLevelRequested extends LocationEvent {
  const LocationLevelRequested(this.level);

  final LocationLevel level;

  @override
  List<Object?> get props => [level];
}
