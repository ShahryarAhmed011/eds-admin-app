part of 'location_bloc.dart';

/// How the drill-down ended.
enum LocationFinish {
  /// A served area was chosen.
  served,

  /// The user asked to be told when their unserved area opens.
  notified,
}

sealed class LocationState extends Equatable {
  const LocationState();

  @override
  List<Object?> get props => [];
}

final class LocationLoading extends LocationState {
  const LocationLoading();
}

final class LocationReady extends LocationState {
  const LocationReady({
    required this.step,
    this.query = '',
    this.notifyPhone = '',
    this.isBusy = false,
    this.openLevel,
    this.finished,
  });

  final LocationStep step;
  final String query;
  final String notifyPhone;
  final bool isBusy;

  /// One-shot: show this level's sheet next.
  final LocationLevel? openLevel;

  /// One-shot: leave the flow.
  final LocationFinish? finished;

  List<LocationOption> get visibleOptions {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return step.options;
    return [
      for (final option in step.options)
        if (option.name.toLowerCase().contains(q)) option,
    ];
  }

  LocationReady copyWith({
    LocationStep? step,
    String? query,
    String? notifyPhone,
    bool? isBusy,
    LocationLevel? openLevel,
    LocationFinish? finished,
  }) => LocationReady(
    step: step ?? this.step,
    query: query ?? this.query,
    notifyPhone: notifyPhone ?? this.notifyPhone,
    isBusy: isBusy ?? this.isBusy,
    openLevel: openLevel,
    finished: finished,
  );

  @override
  List<Object?> get props => [
    step,
    query,
    notifyPhone,
    isBusy,
    openLevel,
    finished,
  ];
}

final class LocationFailure extends LocationState {
  const LocationFailure(this.message, {this.reference});

  final String message;
  final String? reference;

  @override
  List<Object?> get props => [message, reference];
}
