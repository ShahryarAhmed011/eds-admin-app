part of 'admin_scraper_bloc.dart';

sealed class AdminScraperEvent extends Equatable {
  const AdminScraperEvent();

  @override
  List<Object?> get props => [];
}

/// Load the dashboard (configured sources + last run). Jumps to progress
/// when a run is already active.
final class AdminScraperDashboardRequested extends AdminScraperEvent {
  const AdminScraperDashboardRequested();
}

/// "Start scraper" tapped on the ready dashboard.
final class AdminScraperRunStarted extends AdminScraperEvent {
  const AdminScraperRunStarted();
}

/// Import every scraped SKU into the catalogue.
final class AdminScraperImportRequested extends AdminScraperEvent {
  const AdminScraperImportRequested();
}

/// Stop the running catalogue import.
final class AdminScraperImportCancelled extends AdminScraperEvent {
  const AdminScraperImportCancelled();
}

/// Poll timer tick.
final class _AdminScraperPolled extends AdminScraperEvent {
  const _AdminScraperPolled();
}
