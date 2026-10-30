part of 'admin_scraper_bloc.dart';

sealed class AdminScraperState extends Equatable {
  const AdminScraperState();

  @override
  List<Object?> get props => [];
}

final class AdminScraperLoading extends AdminScraperState {
  const AdminScraperLoading();
}

final class AdminScraperReady extends AdminScraperState {
  const AdminScraperReady(
    this.status, {
    this.isStarting = false,
    this.actionError,
  });

  final ScraperStatus status;
  final bool isStarting;

  /// Set right after starting a run failed.
  final String? actionError;

  @override
  List<Object?> get props => [status, isStarting, actionError];
}

final class AdminScraperRunning extends AdminScraperState {
  const AdminScraperRunning(this.status);

  final ScraperStatus status;

  @override
  List<Object?> get props => [status];
}

final class AdminScraperCompleted extends AdminScraperState {
  const AdminScraperCompleted(
    this.results, {
    this.isBusy = false,
    this.actionError,
  });

  final ScraperImportResult results;

  /// An import start/cancel request is in flight.
  final bool isBusy;

  /// Set right after an import action failed.
  final String? actionError;

  @override
  List<Object?> get props => [results, isBusy, actionError];
}

final class AdminScraperFailure extends AdminScraperState {
  const AdminScraperFailure(this.message, {this.reference});

  final String message;
  final String? reference;

  @override
  List<Object?> get props => [message, reference];
}
