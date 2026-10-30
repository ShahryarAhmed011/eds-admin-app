import '../../domain/entities/scraper.dart';
import '../../domain/repository/admin_scraper_repository.dart';
import '../data_sources/admin_scraper_data_source.dart';
import '../mappers/scraper_mapper.dart';

class AdminScraperRepositoryImpl implements AdminScraperRepository {
  const AdminScraperRepositoryImpl(this._dataSource);

  final AdminScraperDataSource _dataSource;

  @override
  Future<ScraperStatus> getStatus() async =>
      (await _dataSource.fetchStatus()).toEntity();

  @override
  Future<ScraperRun> startRun() async =>
      (await _dataSource.startRun()).toEntity();

  /// Combines import-status with per-source row counts. When import-status
  /// has no per-source breakdown, sources come from the scraper status and
  /// rows from `GET /admin/scraper/skus?source=` totals.
  @override
  Future<ScraperImportResult> getImportResults() async {
    final importStatus = await _dataSource.fetchImportStatus();
    if (importStatus.sources.isNotEmpty) {
      return importStatus.toEntity(
        runCode: 'Last run',
        sites: [for (final s in importStatus.sources) s.toSiteResult()],
      );
    }
    final status = await _dataSource.fetchStatus();
    final rows = await Future.wait([
      for (final source in status.sources)
        _dataSource.countSkus(source: source.key),
    ]);
    final run = status.run?.toEntity();
    return importStatus.toEntity(
      runCode: run?.code ?? 'Last run',
      sites: [
        for (var i = 0; i < status.sources.length; i++)
          status.sources[i].toSiteResult(rows: rows[i]),
      ],
    );
  }

  @override
  Future<void> startImportAll() => _dataSource.startImportAll();

  @override
  Future<void> cancelImport() => _dataSource.cancelImport();
}
