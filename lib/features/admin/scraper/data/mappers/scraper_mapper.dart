import '../../domain/entities/scraper.dart';
import '../dto/scraper_dto.dart';

ScraperRunState parseRunState(String? state) => switch (state?.toLowerCase()) {
  'running' || 'queued' || 'pending' || 'started' => ScraperRunState.running,
  'completed' ||
  'succeeded' ||
  'done' ||
  'finished' => ScraperRunState.completed,
  'failed' || 'error' => ScraperRunState.failed,
  'cancelled' || 'canceled' => ScraperRunState.cancelled,
  _ => ScraperRunState.idle,
};

ScraperImportState parseImportState(String? state) =>
    switch (state?.toLowerCase()) {
      'running' ||
      'queued' ||
      'pending' ||
      'started' => ScraperImportState.importing,
      'completed' ||
      'succeeded' ||
      'done' ||
      'finished' => ScraperImportState.imported,
      'cancelled' || 'canceled' => ScraperImportState.cancelled,
      'failed' || 'error' => ScraperImportState.failed,
      _ => ScraperImportState.staged,
    };

extension ScraperSourceDtoMapper on ScraperSourceDto {
  ScraperSource toEntity() => ScraperSource(
    key: key,
    name: name,
    domain: domain,
    scope: scope,
    percent: percentComplete,
    fetchedRows: scraped,
    totalRows: expected,
    currentPage: currentPage,
    totalPages: totalPages,
    isDone: parseRunState(state) == ScraperRunState.completed,
  );

  ScraperSiteResult toSiteResult({int? rows}) => ScraperSiteResult(
    name: name,
    rows: rows ?? scraped,
    staged: staged,
    skipped: skipped,
    failed: failed,
  );
}

extension ScraperRunDtoMapper on ScraperRunDto {
  ScraperRun toEntity() {
    final (before, after) = (catalogueSizeBefore, catalogueSizeAfter);
    return ScraperRun(
      id: id,
      code: code ?? 'Run #$id',
      state: parseRunState(state),
      startedBy: triggeredBy,
      startedAt: startedAt,
      finishedAt: finishedAt,
      importedCount: before == null || after == null ? null : after - before,
      note: note,
    );
  }
}

extension ScraperStatusDtoMapper on ScraperStatusDto {
  ScraperStatus toEntity() => ScraperStatus(
    state: parseRunState(state ?? run?.state),
    percent: percentComplete,
    scraped: scraped,
    run: run?.toEntity(),
    sources: [for (final s in sources) s.toEntity()],
    catalogueLabel: catalogueLabel,
  );
}

extension ScraperImportStatusDtoMapper on ScraperImportStatusDto {
  /// [sites] are the per-site results gathered by the repository.
  ScraperImportResult toEntity({
    required String runCode,
    required List<ScraperSiteResult> sites,
  }) => ScraperImportResult(
    runCode: this.runCode ?? runCode,
    importState: parseImportState(state ?? job?.state),
    importPercent: percentComplete ?? job?.percentComplete,
    processedRows: scrapedTotal ?? job?.total,
    newCount: job?.created,
    matchedCount: job?.replaced,
    duplicateCount: job?.skippedExisting,
    failedCount: job?.failed,
    importedTotal: importedTotal,
    failureNote: failureNote,
    sites: sites,
  );
}
