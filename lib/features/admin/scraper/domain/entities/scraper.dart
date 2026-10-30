import 'package:equatable/equatable.dart';

enum ScraperRunState { idle, running, completed, failed, cancelled }

/// Where the catalogue import of scraped SKUs stands.
enum ScraperImportState { staged, importing, imported, cancelled, failed }

/// A configured scrape source and, while a run is active, its progress.
class ScraperSource extends Equatable {
  const ScraperSource({
    required this.key,
    required this.name,
    this.domain,
    this.scope,
    this.percent,
    this.fetchedRows,
    this.totalRows,
    this.currentPage,
    this.totalPages,
    this.isDone = false,
  });

  /// Source id sent to the API ("metro").
  final String key;
  final String name;
  final String? domain;

  /// What the site is scraped for ("Dairy & pantry").
  final String? scope;
  final int? percent;
  final int? fetchedRows;
  final int? totalRows;
  final int? currentPage;
  final int? totalPages;
  final bool isDone;

  bool get isComplete =>
      isDone ||
      (fetchedRows != null && totalRows != null && fetchedRows! >= totalRows!);

  double get fraction {
    if (percent != null) return percent!.clamp(0, 100) / 100;
    if (fetchedRows != null && totalRows != null && totalRows! > 0) {
      return (fetchedRows! / totalRows!).clamp(0, 1).toDouble();
    }
    return isComplete ? 1 : 0;
  }

  int get displayPercent => percent ?? (fraction * 100).round();

  @override
  List<Object?> get props => [
    key,
    name,
    domain,
    scope,
    percent,
    fetchedRows,
    totalRows,
    currentPage,
    totalPages,
    isDone,
  ];
}

class ScraperRun extends Equatable {
  const ScraperRun({
    required this.id,
    required this.code,
    required this.state,
    this.startedBy,
    this.startedAt,
    this.finishedAt,
    this.importedCount,
    this.note,
  });

  final String id;

  /// Display reference ("SCR-042").
  final String code;
  final ScraperRunState state;
  final String? startedBy;
  final DateTime? startedAt;
  final DateTime? finishedAt;

  /// SKUs added to the catalogue by this run.
  final int? importedCount;
  final String? note;

  @override
  List<Object?> get props => [
    id,
    code,
    state,
    startedBy,
    startedAt,
    finishedAt,
    importedCount,
    note,
  ];
}

/// `GET /admin/scraper/status`: overall state, the current/last run and
/// every source.
class ScraperStatus extends Equatable {
  const ScraperStatus({
    required this.state,
    required this.sources,
    this.percent,
    this.scraped,
    this.run,
    this.catalogueLabel,
  });

  final ScraperRunState state;
  final List<ScraperSource> sources;
  final int? percent;

  /// SKUs written so far.
  final int? scraped;
  final ScraperRun? run;
  final String? catalogueLabel;

  bool get isRunning => state == ScraperRunState.running;

  int? get fetchedRows => _sum((s) => s.fetchedRows);

  int? get totalRows => _sum((s) => s.totalRows);

  int get overallPercent {
    if (percent != null) return percent!;
    final (done, total) = (fetchedRows, totalRows);
    if (done != null && total != null && total > 0) return done * 100 ~/ total;
    return 0;
  }

  int? _sum(int? Function(ScraperSource) read) {
    var total = 0;
    for (final source in sources) {
      final value = read(source);
      if (value == null) return null;
      total += value;
    }
    return sources.isEmpty ? null : total;
  }

  @override
  List<Object?> get props => [
    state,
    sources,
    percent,
    scraped,
    run,
    catalogueLabel,
  ];
}

class ScraperSiteResult extends Equatable {
  const ScraperSiteResult({
    required this.name,
    this.rows,
    this.staged,
    this.skipped,
    this.failed,
  });

  final String name;
  final int? rows;
  final int? staged;
  final int? skipped;
  final int? failed;

  @override
  List<Object?> get props => [name, rows, staged, skipped, failed];
}

class ScraperImportResult extends Equatable {
  const ScraperImportResult({
    required this.runCode,
    required this.importState,
    required this.sites,
    this.importPercent,
    this.processedRows,
    this.newCount,
    this.matchedCount,
    this.duplicateCount,
    this.failedCount,
    this.importedTotal,
    this.failureNote,
  });

  final String runCode;
  final ScraperImportState importState;
  final List<ScraperSiteResult> sites;
  final int? importPercent;
  final int? processedRows;
  final int? newCount;
  final int? matchedCount;
  final int? duplicateCount;
  final int? failedCount;

  /// Scraped SKUs already in the catalogue.
  final int? importedTotal;

  /// Why rows failed ("missing barcode or invalid pack size").
  final String? failureNote;

  int? get stagedCount => newCount == null || matchedCount == null
      ? null
      : newCount! + matchedCount!;

  bool get isImporting => importState == ScraperImportState.importing;

  @override
  List<Object?> get props => [
    runCode,
    importState,
    sites,
    importPercent,
    processedRows,
    newCount,
    matchedCount,
    duplicateCount,
    failedCount,
    importedTotal,
    failureNote,
  ];
}
