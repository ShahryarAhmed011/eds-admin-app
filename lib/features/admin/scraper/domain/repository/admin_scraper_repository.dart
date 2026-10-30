import '../entities/scraper.dart';

abstract interface class AdminScraperRepository {
  /// Current scraper state: the active run, or the last one when idle.
  Future<ScraperStatus> getStatus();

  /// Starts a scrape of every configured source.
  Future<ScraperRun> startRun();

  /// Staged/imported counts of the last run, overall and per site.
  Future<ScraperImportResult> getImportResults();

  /// Imports every scraped SKU into the catalogue in the background.
  Future<void> startImportAll();

  /// Stops the running import; rows already imported stay imported.
  Future<void> cancelImport();
}
