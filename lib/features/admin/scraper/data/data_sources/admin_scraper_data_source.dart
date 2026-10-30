import '../dto/scraper_dto.dart';

abstract interface class AdminScraperDataSource {
  /// The active run, or the last one when idle.
  Future<ScraperStatusDto> fetchStatus();

  Future<ScraperRunDto> startRun();

  Future<ScraperImportStatusDto> fetchImportStatus();

  /// Total scraped SKUs, optionally for one source / import state.
  Future<int?> countSkus({String? source, bool? imported});

  Future<ScraperImportJobDto> startImportAll();

  Future<ScraperImportJobDto> cancelImport();
}
