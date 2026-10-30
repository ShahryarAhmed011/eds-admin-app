import 'package:eds_admin_app/features/admin/scraper/data/dto/scraper_dto.dart';
import 'package:eds_admin_app/features/admin/scraper/data/mappers/scraper_mapper.dart';
import 'package:eds_admin_app/features/admin/scraper/domain/entities/scraper.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('maps GET /admin/scraper/status while running', () {
    final status = ScraperStatusDto.fromJson({
      'state': 'running',
      'percentComplete': 74,
      'scraped': 378,
      'catalogueSize': 1248,
      'expectedMinimumSkus': 500,
      'mode': 'full',
      'run': {
        'id': 42,
        'state': 'running',
        'triggeredBy': 5,
        'startedAt': '2026-10-16T04:41:00Z',
      },
      'sources': ['metro', 'naheed'],
    }).toEntity();

    expect(status.isRunning, isTrue);
    expect(status.overallPercent, 74);
    expect(status.run!.code, 'Run #42');
    expect(status.run!.startedBy, '5');
    expect(status.sources.map((s) => s.name), ['metro', 'naheed']);
    expect(status.fetchedRows, isNull);
  });

  test('maps per-source progress objects', () {
    final source = ScraperSourceDto.fromJson({
      'source': 'naheed',
      'name': 'Naheed',
      'scraped': 140,
      'expected': 200,
      'currentPage': 7,
      'totalPages': 10,
    }).toEntity();

    expect(source.displayPercent, 70);
    expect(source.isComplete, isFalse);
  });

  test('maps GET /admin/scraper/import-status job counts', () {
    final results = ScraperImportStatusDto.fromJson({
      'state': 'completed',
      'percentComplete': 100,
      'job': {
        'id': 7,
        'state': 'completed',
        'total': 510,
        'done': 510,
        'created': 80,
        'replaced': 180,
        'skippedExisting': 230,
      },
      'scrapedTotal': 510,
      'importedTotal': 260,
    }).toEntity(runCode: 'Run #42', sites: const []);

    expect(results.importState, ScraperImportState.imported);
    expect(results.stagedCount, 260);
    expect(results.duplicateCount, 230);
    expect(results.failedCount, isNull);
    expect(results.runCode, 'Run #42');
  });
}
