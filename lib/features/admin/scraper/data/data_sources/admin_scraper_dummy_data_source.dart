import '../../../../../core/core.dart';
import '../dto/scraper_dto.dart';
import 'admin_scraper_data_source.dart';

/// Prefilled data matching the Figma scraper screens, in the API's shape.
///
/// "Start scraper" simulates a run that progresses with wall-clock time
/// (sites finish at different speeds) and completes after [runDuration];
/// "Import" likewise completes after [importDuration]. The instance is a
/// lazy singleton, so the run keeps going while the screen is closed.
class AdminScraperDummyDataSource implements AdminScraperDataSource {
  AdminScraperDummyDataSource({
    this.runDuration = const Duration(seconds: 8),
    this.importDuration = const Duration(seconds: 6),
    DateTime Function()? clock,
  }) : _now = clock ?? DateTime.now;

  static const activeRunId = 'SCR-042';

  final Duration runDuration;
  final Duration importDuration;
  final DateTime Function() _now;

  DateTime? _runStartedAt;
  bool _completed = false;
  String _importState = 'idle';
  DateTime? _importStartedAt;

  bool get _running => _runStartedAt != null && !_completed;

  /// Share of [runDuration] elapsed, 0..1.
  double get _runFraction {
    final started = _runStartedAt;
    if (started == null) return 0;
    final f =
        _now().difference(started).inMilliseconds / runDuration.inMilliseconds;
    return f.clamp(0, 1).toDouble();
  }

  static const _sourceInfo = [
    {
      'source': 'metro',
      'name': 'Metro Pakistan',
      'domain': 'metro.pk',
      'scope': 'Dairy & pantry',
    },
    {
      'source': 'naheed',
      'name': 'Naheed',
      'domain': 'naheed.pk',
      'scope': 'Grocery',
    },
    {
      'source': 'alfatah',
      'name': 'Al-Fatah',
      'domain': 'alfatah.pk',
      'scope': 'Essentials',
    },
  ];

  /// Expected rows per source, and how much faster than the slowest
  /// source each one runs.
  static const _expected = [220, 200, 90];
  static const _speed = [1.8, 1.3, 1.0];

  static const _results = [
    {'staged': 110, 'skipped': 110, 'failed': 0},
    {'staged': 100, 'skipped': 90, 'failed': 10},
    {'staged': 50, 'skipped': 30, 'failed': 10},
  ];

  static const _lastRun = {
    'id': 'SCR-041',
    'code': 'SCR-041',
    'state': 'completed',
    'startedAt': '2026-10-15T17:20:00+05:00',
    'finishedAt': '2026-10-15T18:00:00+05:00',
    'catalogueSizeBefore': 1006,
    'catalogueSizeAfter': 1248,
    'note': 'Manual review required for new variants.',
  };

  static const _activeRun = {
    'id': activeRunId,
    'code': activeRunId,
    'triggeredBy': {'name': 'Nadia'},
    'startedAt': '2026-10-16T09:41:00+05:00',
  };

  @override
  Future<ScraperStatusDto> fetchStatus() async {
    await dummyDelay();
    if (_running && _runFraction >= 1) _completed = true;
    if (!_running) {
      return ScraperStatusDto.fromJson({
        'state': _completed ? 'completed' : 'idle',
        'percentComplete': _completed ? 100 : 0,
        'catalogueLabel': 'Pakistan grocery catalogue',
        'run': _completed ? {..._activeRun, 'state': 'completed'} : _lastRun,
        'sources': [
          for (final info in _sourceInfo) {...info, 'percentComplete': 0},
        ],
      });
    }
    final f = _runFraction;
    final scrapedPerSource = [
      for (var i = 0; i < _expected.length; i++)
        (_expected[i] * (f * _speed[i]).clamp(0, 1)).round(),
    ];
    final scraped = scrapedPerSource.fold(0, (sum, n) => sum + n);
    final expected = _expected.fold(0, (sum, n) => sum + n);
    return ScraperStatusDto.fromJson({
      'state': 'running',
      'percentComplete': scraped * 100 ~/ expected,
      'scraped': scraped,
      'run': {..._activeRun, 'state': 'running'},
      'sources': [
        for (var i = 0; i < _sourceInfo.length; i++)
          {
            ..._sourceInfo[i],
            'state': scrapedPerSource[i] >= _expected[i]
                ? 'completed'
                : 'running',
            'scraped': scrapedPerSource[i],
            'expected': _expected[i],
            'currentPage': (scrapedPerSource[i] * 10 / _expected[i]).ceil(),
            'totalPages': 10,
          },
      ],
    });
  }

  @override
  Future<ScraperRunDto> startRun() async {
    await dummyDelay();
    if (_running) {
      throw const ApiException(
        status: 409,
        code: ApiErrorCode.scrapeRunActive,
        message: 'A scrape is already running.',
      );
    }
    _begin();
    return ScraperRunDto.fromJson({..._activeRun, 'state': 'running'});
  }

  void _begin() {
    _runStartedAt = _now();
    _completed = false;
    _importState = 'idle';
    _importStartedAt = null;
  }

  @override
  Future<ScraperImportStatusDto> fetchImportStatus() async {
    await dummyDelay();
    var percent = 0;
    final importStarted = _importStartedAt;
    if (_importState == 'running' && importStarted != null) {
      percent =
          (_now().difference(importStarted).inMilliseconds *
                  100 ~/
                  importDuration.inMilliseconds)
              .clamp(0, 100);
      if (percent >= 100) _importState = 'completed';
    } else if (_importState == 'completed') {
      percent = 100;
    }
    return ScraperImportStatusDto.fromJson({
      'state': _importState,
      'percentComplete': percent,
      'runCode': activeRunId,
      'failureNote': 'missing barcode or invalid pack size',
      'scrapedTotal': 510,
      'importedTotal': _importState == 'completed' ? 260 : 0,
      'job': {
        'id': 'IMP-007',
        'state': _importState,
        'total': 510,
        'created': 80,
        'replaced': 180,
        'skippedExisting': 230,
        'failed': 20,
      },
      'sources': [
        for (var i = 0; i < _sourceInfo.length; i++)
          {..._sourceInfo[i], 'scraped': _expected[i], ..._results[i]},
      ],
    });
  }

  @override
  Future<int?> countSkus({String? source, bool? imported}) async {
    await dummyDelay();
    final index = _sourceInfo.indexWhere((s) => s['source'] == source);
    return index < 0 ? 510 : _expected[index];
  }

  @override
  Future<ScraperImportJobDto> startImportAll() async {
    await dummyDelay();
    if (_importState == 'running') {
      throw const ApiException(
        status: 409,
        code: ApiErrorCode.catalogImportActive,
        message: 'An import is already running.',
      );
    }
    _importState = 'running';
    _importStartedAt = _now();
    return ScraperImportJobDto.fromJson(const {
      'id': 'IMP-007',
      'state': 'running',
    });
  }

  @override
  Future<ScraperImportJobDto> cancelImport() async {
    await dummyDelay();
    _importState = 'cancelled';
    return ScraperImportJobDto.fromJson(const {
      'id': 'IMP-007',
      'state': 'cancelled',
    });
  }
}
