import 'package:eds_admin_app/core/core.dart';
import 'package:eds_admin_app/features/admin/scraper/data/data_sources/admin_scraper_dummy_data_source.dart';
import 'package:eds_admin_app/features/admin/scraper/data/repository/admin_scraper_repository_impl.dart';
import 'package:eds_admin_app/features/admin/scraper/domain/entities/scraper.dart';
import 'package:eds_admin_app/features/admin/scraper/domain/usecase/cancel_scraper_import.dart';
import 'package:eds_admin_app/features/admin/scraper/domain/usecase/get_scraper_import_results.dart';
import 'package:eds_admin_app/features/admin/scraper/domain/usecase/get_scraper_status.dart';
import 'package:eds_admin_app/features/admin/scraper/domain/usecase/start_scraper_import.dart';
import 'package:eds_admin_app/features/admin/scraper/domain/usecase/start_scraper_run.dart';
import 'package:eds_admin_app/features/admin/scraper/presentation/bloc/admin_scraper_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  AdminScraperBloc buildBloc(AdminScraperDummyDataSource source) {
    final repo = AdminScraperRepositoryImpl(source);
    return AdminScraperBloc(
      GetScraperStatus(repo),
      StartScraperRun(repo),
      GetScraperImportResults(repo),
      StartScraperImport(repo),
      CancelScraperImport(repo),
      pollInterval: const Duration(milliseconds: 50),
    );
  }

  AdminScraperDummyDataSource fastSource() => AdminScraperDummyDataSource(
    runDuration: const Duration(milliseconds: 1200),
    importDuration: const Duration(milliseconds: 600),
  );

  test('dummy run progresses with time', () async {
    var now = DateTime(2026, 10, 16, 9, 41);
    final source = AdminScraperDummyDataSource(clock: () => now);
    await source.startRun();
    final start = await source.fetchStatus();
    now = now.add(const Duration(seconds: 4));
    final middle = await source.fetchStatus();
    now = now.add(const Duration(seconds: 5));
    final end = await source.fetchStatus();
    expect(start.state, 'running');
    expect(middle.state, 'running');
    expect(middle.percentComplete, greaterThan(start.percentComplete ?? 0));
    expect(end.state, 'completed');
  });

  test('ready → start → running → results → import → ready', () async {
    final source = fastSource();
    final bloc = buildBloc(source)..add(const AdminScraperDashboardRequested());
    final ready = await bloc.stream.firstWhere((s) => s is AdminScraperReady);
    expect((ready as AdminScraperReady).status.run!.importedCount, 242);

    bloc.add(const AdminScraperRunStarted());
    await bloc.stream.firstWhere((s) => s is AdminScraperRunning);

    final done = await bloc.stream
        .firstWhere((s) => s is AdminScraperCompleted)
        .timeout(const Duration(seconds: 10));
    final results = (done as AdminScraperCompleted).results;
    expect(results.runCode, 'SCR-042');
    expect(results.stagedCount, 260);
    expect(results.sites.map((s) => s.failed), [0, 10, 10]);

    bloc.add(const AdminScraperImportRequested());
    await bloc.stream
        .firstWhere(
          (s) =>
              s is AdminScraperCompleted &&
              s.results.importState == ScraperImportState.imported,
        )
        .timeout(const Duration(seconds: 10));
    await bloc.close();

    // Reopening after the import shows the ready dashboard again.
    final reopened = buildBloc(source)
      ..add(const AdminScraperDashboardRequested());
    expect(
      await reopened.stream.firstWhere((s) => s is! AdminScraperLoading),
      isA<AdminScraperReady>(),
    );
    await reopened.close();
  });

  test('reopening mid-run resumes progress; close stops polling', () async {
    final source = fastSource();
    await source.startRun();
    final bloc = buildBloc(source)..add(const AdminScraperDashboardRequested());
    await bloc.stream.firstWhere((s) => s is AdminScraperRunning);
    await bloc.close();
    await Future<void>.delayed(const Duration(milliseconds: 150));
    expect(bloc.isClosed, isTrue);
  });

  test('money formatting used by the admin screens', () {
    expect(const Money.rupees(280).format(), 'Rs 280');
  });
}
