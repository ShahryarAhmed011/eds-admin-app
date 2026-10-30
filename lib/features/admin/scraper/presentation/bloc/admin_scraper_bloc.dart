import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/core.dart';
import '../../domain/entities/scraper.dart';
import '../../domain/usecase/cancel_scraper_import.dart';
import '../../domain/usecase/get_scraper_import_results.dart';
import '../../domain/usecase/get_scraper_status.dart';
import '../../domain/usecase/start_scraper_import.dart';
import '../../domain/usecase/start_scraper_run.dart';

part 'admin_scraper_event.dart';
part 'admin_scraper_state.dart';

/// Drives the single scraper screen. What it shows comes from the run
/// state: ready (idle, or last import done) → running progress → import
/// results. While a scrape or an import runs, the status is polled every
/// [pollInterval]; the timer is cancelled in [close].
class AdminScraperBloc extends Bloc<AdminScraperEvent, AdminScraperState> {
  AdminScraperBloc(
    this._getStatus,
    this._startRun,
    this._getResults,
    this._startImport,
    this._cancelImport, {
    this.pollInterval = const Duration(seconds: 2),
  }) : super(const AdminScraperLoading()) {
    on<AdminScraperDashboardRequested>(_onDashboardRequested);
    on<AdminScraperRunStarted>(_onRunStarted);
    on<AdminScraperImportRequested>(_onImportRequested);
    on<AdminScraperImportCancelled>(_onImportCancelled);
    on<_AdminScraperPolled>(_onPolled);
  }

  final GetScraperStatus _getStatus;
  final StartScraperRun _startRun;
  final GetScraperImportResults _getResults;
  final StartScraperImport _startImport;
  final CancelScraperImport _cancelImport;
  final Duration pollInterval;

  Timer? _timer;
  bool _polling = false;

  Future<void> _onDashboardRequested(
    AdminScraperDashboardRequested event,
    Emitter<AdminScraperState> emit,
  ) async {
    emit(const AdminScraperLoading());
    try {
      final status = await _getStatus(const NoParams());
      switch (status.state) {
        case ScraperRunState.running:
          emit(AdminScraperRunning(status));
          _startPolling();
        case ScraperRunState.completed:
          // A finished run whose import is still pending shows its results;
          // once imported, the dashboard is ready for the next run.
          final results = await _getResults(const NoParams());
          if (results.importState == ScraperImportState.imported) {
            emit(AdminScraperReady(status));
          } else {
            emit(AdminScraperCompleted(results));
            if (results.isImporting) _startPolling();
          }
        default:
          emit(AdminScraperReady(status));
      }
    } catch (e) {
      emit(_failure(e));
    }
  }

  Future<void> _onRunStarted(
    AdminScraperRunStarted event,
    Emitter<AdminScraperState> emit,
  ) async {
    final current = state;
    if (current is! AdminScraperReady || current.isStarting) return;
    emit(AdminScraperReady(current.status, isStarting: true));
    try {
      await _startRun(const NoParams());
    } on ApiException catch (e) {
      // Someone else already started a run: follow it instead.
      if (e.code != ApiErrorCode.scrapeRunActive) {
        emit(AdminScraperReady(current.status, actionError: errorMessage(e)));
        return;
      }
    } catch (e) {
      emit(AdminScraperReady(current.status, actionError: errorMessage(e)));
      return;
    }
    await _refreshRun(emit);
  }

  Future<void> _onImportRequested(
    AdminScraperImportRequested event,
    Emitter<AdminScraperState> emit,
  ) async {
    final current = state;
    if (current is! AdminScraperCompleted || current.isBusy) return;
    emit(AdminScraperCompleted(current.results, isBusy: true));
    try {
      await _startImport(const NoParams());
    } on ApiException catch (e) {
      if (e.code != ApiErrorCode.catalogImportActive) {
        emit(
          AdminScraperCompleted(current.results, actionError: errorMessage(e)),
        );
        return;
      }
    } catch (e) {
      emit(
        AdminScraperCompleted(current.results, actionError: errorMessage(e)),
      );
      return;
    }
    await _refreshResults(emit);
  }

  Future<void> _onImportCancelled(
    AdminScraperImportCancelled event,
    Emitter<AdminScraperState> emit,
  ) async {
    final current = state;
    if (current is! AdminScraperCompleted || current.isBusy) return;
    emit(AdminScraperCompleted(current.results, isBusy: true));
    try {
      await _cancelImport(const NoParams());
      await _refreshResults(emit);
    } catch (e) {
      emit(
        AdminScraperCompleted(current.results, actionError: errorMessage(e)),
      );
    }
  }

  Future<void> _onPolled(
    _AdminScraperPolled event,
    Emitter<AdminScraperState> emit,
  ) async {
    if (_polling) return;
    _polling = true;
    try {
      switch (state) {
        case AdminScraperRunning():
          await _refreshRun(emit, quiet: true);
        case AdminScraperCompleted(isBusy: false):
          await _refreshResults(emit, quiet: true);
        default:
          _stopPolling();
      }
    } finally {
      _polling = false;
    }
  }

  /// Fetches the run status and moves to results once collection ends.
  /// A [quiet] refresh keeps the current screen on transient errors.
  Future<void> _refreshRun(
    Emitter<AdminScraperState> emit, {
    bool quiet = false,
  }) async {
    try {
      final status = await _getStatus(const NoParams());
      switch (status.state) {
        case ScraperRunState.running:
          emit(AdminScraperRunning(status));
          _startPolling();
        case ScraperRunState.completed:
          _stopPolling();
          await _refreshResults(emit);
        case ScraperRunState.idle:
          _stopPolling();
          emit(AdminScraperReady(status));
        case ScraperRunState.failed || ScraperRunState.cancelled:
          _stopPolling();
          emit(
            AdminScraperReady(
              status,
              actionError:
                  'Run ${status.run?.code ?? ''} '
                  '${status.state == ScraperRunState.failed ? 'failed' : 'was cancelled'}.',
            ),
          );
      }
    } catch (e) {
      if (!quiet) {
        _stopPolling();
        emit(_failure(e));
      }
    }
  }

  /// Fetches import results; keeps polling while the import runs.
  Future<void> _refreshResults(
    Emitter<AdminScraperState> emit, {
    bool quiet = false,
  }) async {
    try {
      final results = await _getResults(const NoParams());
      emit(AdminScraperCompleted(results));
      results.isImporting ? _startPolling() : _stopPolling();
    } catch (e) {
      if (!quiet) {
        _stopPolling();
        emit(_failure(e));
      }
    }
  }

  void _startPolling() {
    _timer ??= Timer.periodic(pollInterval, (_) {
      if (!isClosed) add(const _AdminScraperPolled());
    });
  }

  void _stopPolling() {
    _timer?.cancel();
    _timer = null;
  }

  AdminScraperFailure _failure(Object e) =>
      AdminScraperFailure(errorMessage(e), reference: errorReference(e));

  @override
  Future<void> close() {
    _stopPolling();
    return super.close();
  }
}
