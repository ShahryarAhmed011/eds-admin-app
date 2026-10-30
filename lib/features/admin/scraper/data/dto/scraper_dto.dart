import '../../../../../core/core.dart';

String? _firstStr(Json json, List<String> keys) {
  for (final key in keys) {
    final value = json.str(key);
    if (value != null && value.isNotEmpty) return value;
  }
  return null;
}

int? _firstInt(Json json, List<String> keys) {
  for (final key in keys) {
    final value = json.integer(key);
    if (value != null) return value;
  }
  return null;
}

/// One entry of `status.sources`. The per-source shape is not modelled in
/// the API docs, so likely key names are tried in turn.
class ScraperSourceDto {
  const ScraperSourceDto({
    required this.key,
    required this.name,
    this.domain,
    this.scope,
    this.state,
    this.percentComplete,
    this.scraped,
    this.expected,
    this.currentPage,
    this.totalPages,
    this.staged,
    this.skipped,
    this.failed,
  });

  factory ScraperSourceDto.fromJson(Json json) {
    final key = _firstStr(json, ['source', 'key', 'slug', 'name']) ?? '';
    return ScraperSourceDto(
      key: key,
      name: _firstStr(json, ['name', 'label', 'displayName']) ?? key,
      domain: _firstStr(json, ['domain', 'host', 'baseUrl']),
      scope: _firstStr(json, ['scope', 'description']),
      state: json.str('state'),
      percentComplete: json.integer('percentComplete'),
      scraped: _firstInt(json, ['scraped', 'fetched', 'rowsFetched']),
      expected: _firstInt(json, ['expected', 'total', 'expectedSkus']),
      currentPage: _firstInt(json, ['currentPage', 'page']),
      totalPages: _firstInt(json, ['totalPages', 'pages']),
      staged: json.integer('staged'),
      skipped: _firstInt(json, ['skipped', 'skippedExisting']),
      failed: json.integer('failed'),
    );
  }

  /// Bare source names (`["metro", ...]`) are accepted too.
  static List<ScraperSourceDto> listFrom(Object? raw) => [
    if (raw is List)
      for (final item in raw)
        if (item is Map)
          ScraperSourceDto.fromJson(item.cast<String, dynamic>())
        else if (item != null)
          ScraperSourceDto(key: '$item', name: '$item'),
  ];

  final String key;
  final String name;
  final String? domain;
  final String? scope;
  final String? state;
  final int? percentComplete;
  final int? scraped;
  final int? expected;
  final int? currentPage;
  final int? totalPages;
  final int? staged;
  final int? skipped;
  final int? failed;
}

/// A scrape run (`POST /admin/scraper/start`, `status.run`).
class ScraperRunDto {
  const ScraperRunDto({
    required this.id,
    this.code,
    this.state,
    this.percentComplete,
    this.triggeredBy,
    this.startedAt,
    this.finishedAt,
    this.catalogueSizeBefore,
    this.catalogueSizeAfter,
    this.note,
  });

  factory ScraperRunDto.fromJson(Json json) {
    final trigger = json.obj('triggeredBy');
    return ScraperRunDto(
      id: json.id(),
      code: json.str('code'),
      state: json.str('state'),
      percentComplete: json.integer('percentComplete'),
      triggeredBy: trigger == null
          ? json.str('triggeredBy')
          : _firstStr(trigger, ['name', 'fullName', 'email']),
      startedAt: json.date('startedAt') ?? json.date('createdAt'),
      finishedAt: json.date('finishedAt'),
      catalogueSizeBefore: json.integer('catalogueSizeBefore'),
      catalogueSizeAfter: json.integer('catalogueSizeAfter'),
      note: json.str('note'),
    );
  }

  final String id;
  final String? code;
  final String? state;
  final int? percentComplete;
  final String? triggeredBy;
  final DateTime? startedAt;
  final DateTime? finishedAt;
  final int? catalogueSizeBefore;
  final int? catalogueSizeAfter;
  final String? note;
}

/// `GET /admin/scraper/status`.
class ScraperStatusDto {
  const ScraperStatusDto({
    required this.sources,
    this.state,
    this.percentComplete,
    this.scraped,
    this.run,
    this.catalogueLabel,
  });

  factory ScraperStatusDto.fromJson(Json json) => ScraperStatusDto(
    state: json.str('state'),
    percentComplete: json.integer('percentComplete'),
    scraped: json.integer('scraped'),
    run: json.obj('run') == null
        ? null
        : ScraperRunDto.fromJson(json.obj('run')!),
    sources: ScraperSourceDto.listFrom(json['sources']),
    catalogueLabel: json.str('catalogueLabel'),
  );

  final String? state;
  final int? percentComplete;
  final int? scraped;
  final ScraperRunDto? run;
  final List<ScraperSourceDto> sources;
  final String? catalogueLabel;
}

/// The import job (`POST /admin/scraper/import-all`, `import-status.job`).
class ScraperImportJobDto {
  const ScraperImportJobDto({
    this.id,
    this.state,
    this.percentComplete,
    this.total,
    this.done,
    this.created,
    this.replaced,
    this.skippedExisting,
    this.failed,
  });

  factory ScraperImportJobDto.fromJson(Json json) => ScraperImportJobDto(
    id: json.str('id'),
    state: json.str('state'),
    percentComplete: json.integer('percentComplete'),
    total: json.integer('total'),
    done: json.integer('done'),
    created: json.integer('created'),
    replaced: json.integer('replaced'),
    skippedExisting: json.integer('skippedExisting'),
    failed: json.integer('failed'),
  );

  final String? id;
  final String? state;
  final int? percentComplete;
  final int? total;
  final int? done;
  final int? created;
  final int? replaced;
  final int? skippedExisting;
  final int? failed;
}

/// `GET /admin/scraper/import-status`. `run_code`, `failure_note` and
/// `sources` are only sent by the dummy source.
class ScraperImportStatusDto {
  const ScraperImportStatusDto({
    required this.sources,
    this.state,
    this.percentComplete,
    this.job,
    this.scrapedTotal,
    this.importedTotal,
    this.runCode,
    this.failureNote,
  });

  factory ScraperImportStatusDto.fromJson(Json json) => ScraperImportStatusDto(
    state: json.str('state'),
    percentComplete: json.integer('percentComplete'),
    job: json.obj('job') == null
        ? null
        : ScraperImportJobDto.fromJson(json.obj('job')!),
    scrapedTotal: json.integer('scrapedTotal'),
    importedTotal: json.integer('importedTotal'),
    runCode: json.str('runCode'),
    failureNote: json.str('failureNote'),
    sources: ScraperSourceDto.listFrom(json['sources']),
  );

  final String? state;
  final int? percentComplete;
  final ScraperImportJobDto? job;
  final int? scrapedTotal;
  final int? importedTotal;
  final String? runCode;
  final String? failureNote;
  final List<ScraperSourceDto> sources;
}
