import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/core.dart';
import '../../../../../core/di/injection.dart';
import '../../../audit_log/presentation/widgets/admin_time_format.dart';
import '../../../catalogue/presentation/widgets/admin_fact_card.dart';
import '../../domain/entities/scraper.dart';
import '../bloc/admin_scraper_bloc.dart';
import '../widgets/scraper_site_progress_card.dart';
import '../widgets/scraper_site_tile.dart';

/// Catalogue scraper (More → Catalogue scraper). One screen whose content
/// follows the run state: ready dashboard, live progress by site, or SKU
/// import results. Starting a run switches it to progress, and a finished
/// run switches it to results.
class AdminScraperScreen extends StatelessWidget {
  const AdminScraperScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          sl<AdminScraperBloc>()..add(const AdminScraperDashboardRequested()),
      child: const _AdminScraperView(),
    );
  }
}

class _AdminScraperView extends StatelessWidget {
  const _AdminScraperView();

  static String? _actionError(AdminScraperState state) => switch (state) {
    AdminScraperReady(:final actionError) => actionError,
    AdminScraperCompleted(:final actionError) => actionError,
    _ => null,
  };

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AdminScraperBloc, AdminScraperState>(
      listenWhen: (_, current) => _actionError(current) != null,
      listener: (context, state) => EdsToast.of(
        context,
      ).show(_actionError(state)!, kind: EdsToastKind.error),
      builder: (context, state) {
        final bloc = context.read<AdminScraperBloc>();
        final title = switch (state) {
          AdminScraperRunning() => 'Scraper running',
          AdminScraperCompleted() => 'SKU import results',
          _ => 'Catalogue scraper',
        };
        return EdsScaffold(
          title: title,
          bottomNav: const EdsBottomNav(
            items: RoleNavs.admin,
            currentIndex: AdminTab.more,
          ),
          bottomAction: switch (state) {
            AdminScraperReady(:final isStarting) => EdsButton.primary(
              label: 'Start scraper',
              isLoading: isStarting,
              onPressed: () => bloc.add(const AdminScraperRunStarted()),
            ),
            AdminScraperCompleted(:final results) => EdsButton.primary(
              label: results.newCount == null
                  ? 'Review new variants'
                  : 'Review ${results.newCount} new variants',
              onPressed: () => context.go(AppRoutes.adminCatalogueVariants),
            ),
            _ => null,
          },
          body: switch (state) {
            AdminScraperLoading() => const EdsLoadingView(),
            AdminScraperFailure(:final message, :final reference) =>
              EdsErrorView(
                message: message,
                reference: reference,
                onRetry: () => bloc.add(const AdminScraperDashboardRequested()),
              ),
            AdminScraperReady(:final status) => _ReadyContent(status),
            AdminScraperRunning(:final status) => _ProgressContent(status),
            AdminScraperCompleted(:final results, :final isBusy) =>
              _ResultsContent(results, isBusy: isBusy),
          },
        );
      },
    );
  }
}

class _ReadyContent extends StatelessWidget {
  const _ReadyContent(this.status);

  final ScraperStatus status;

  @override
  Widget build(BuildContext context) {
    final lastRun = status.run;
    final finished = lastRun?.finishedAt;
    final imported = lastRun?.importedCount;
    final lastRunLine = [
      if (finished != null) formatAdminDayTime(finished),
      if (imported != null) '$imported SKUs imported',
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const EdsBanner(
          title: 'Ready · No run in progress',
          message:
              'Collect source data, then review SKU import results before '
              'publishing.',
        ),
        AppSpacing.gapXl,
        EdsSectionHeader(
          title: 'Configured sources',
          subtitle: [
            '${status.sources.length} sites',
            ?status.catalogueLabel,
          ].join(' · '),
        ),
        AppSpacing.gapLg,
        EdsGroupCard(
          children: [
            for (final source in status.sources)
              ScraperSiteTile(
                name: source.name,
                subtitle: [
                  ?source.domain,
                  ?source.scope,
                  '${source.displayPercent}%',
                ].join(' · '),
                badge: 'Ready',
              ),
          ],
        ),
        if (lastRun != null) ...[
          AppSpacing.gapLg,
          AdminFactCard(
            title: 'Last run · ${lastRun.code}',
            lines: [if (lastRunLine.isNotEmpty) lastRunLine.join(' · ')],
            footnote: lastRun.note,
          ),
        ],
      ],
    );
  }
}

class _ProgressContent extends StatelessWidget {
  const _ProgressContent(this.status);

  final ScraperStatus status;

  @override
  Widget build(BuildContext context) {
    final run = status.run;
    final started = [
      if (run?.startedBy != null) 'by ${run!.startedBy}',
      if (run?.startedAt != null) 'at ${formatAdminTime(run!.startedAt!)}',
    ];
    final (fetched, total) = (status.fetchedRows, status.totalRows);
    final sites = '${status.sources.length} sites';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        EdsBanner(
          title: ['Running', ?run?.code].join(' · '),
          message:
              '${started.isEmpty ? 'Started' : 'Started ${started.join(' ')}'}'
              '. You can leave this screen; the run continues.',
          tone: EdsTone.warning,
        ),
        AppSpacing.gapXl,
        EdsSectionHeader(
          title: 'Overall progress · ${status.overallPercent}%',
          subtitle: fetched != null && total != null
              ? '$fetched of $total source rows fetched · $sites'
              : status.scraped != null
              ? '${status.scraped} SKUs fetched · $sites'
              : sites,
        ),
        for (final site in status.sources) ...[
          AppSpacing.gapMd,
          ScraperSiteProgressCard(site: site),
        ],
        AppSpacing.gapLg,
        Text(
          'SKU matching and import start after collection. Nothing is '
          'published until review is complete.',
          style: AppTextStyles.bodySecondary,
        ),
      ],
    );
  }
}

class _ResultsContent extends StatelessWidget {
  const _ResultsContent(this.results, {required this.isBusy});

  final ScraperImportResult results;
  final bool isBusy;

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<AdminScraperBloc>();
    final processed = results.processedRows == null
        ? 'Source rows processed.'
        : '${results.processedRows} source rows processed.';
    final banner = switch (results.importState) {
      ScraperImportState.importing => EdsBanner(
        title: 'Importing · ${results.importPercent ?? 0}%',
        message:
            'Scraped SKUs are being added to the global catalogue. Rows '
            'already imported stay imported if you cancel.',
        tone: EdsTone.warning,
      ),
      ScraperImportState.imported => EdsBanner(
        title: 'Imported · ${results.runCode}',
        message:
            '$processed ${results.importedTotal ?? results.stagedCount ?? ''} '
            'SKUs are in the global catalogue.',
      ),
      _ => EdsBanner(
        title: 'Completed · ${results.runCode}',
        message: '$processed Import is staged; global catalogue is unchanged.',
      ),
    };
    final summary = [
      if (results.newCount != null && results.matchedCount != null)
        '${results.newCount} new · ${results.matchedCount} matched updates',
      [
        if (results.duplicateCount != null)
          '${results.duplicateCount} duplicates skipped',
        if (results.failedCount != null) '${results.failedCount} rows failed',
      ].join(' · '),
    ].where((line) => line.isNotEmpty).toList();
    final failed = results.failedCount ?? 0;
    final staged = results.stagedCount;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        banner,
        if (staged != null || summary.isNotEmpty) ...[
          AppSpacing.gapLg,
          AdminFactCard(
            title: staged == null
                ? 'SKUs staged for review'
                : '$staged SKUs staged for review',
            lines: summary,
          ),
        ],
        AppSpacing.gapXl,
        const EdsSectionHeader(title: 'Per-site results · 100%'),
        AppSpacing.gapLg,
        EdsGroupCard(
          children: [
            for (final site in results.sites)
              ScraperSiteTile(
                name: site.name,
                subtitle: [
                  if (site.rows != null) '${site.rows} rows',
                  if (site.staged != null) '${site.staged} staged',
                  if (site.skipped != null) '${site.skipped} skipped',
                  if ((site.failed ?? 0) > 0) '${site.failed} failed',
                ].join(' · '),
                badge: (site.failed ?? 0) > 0
                    ? '${site.failed} failed'
                    : 'Done',
                badgeTone: (site.failed ?? 0) > 0
                    ? EdsTone.warning
                    : EdsTone.success,
              ),
          ],
        ),
        if (failed > 0) ...[
          AppSpacing.gapLg,
          if (results.failureNote != null) ...[
            Text(
              'Failed rows: ${results.failureNote}.',
              style: AppTextStyles.bodySecondary.copyWith(color: AppColors.ink),
            ),
            AppSpacing.gapLg,
          ],
          EdsButton.secondary(
            label: 'Download $failed failed rows',
            onPressed: () => EdsToast.of(context).show(
              '$failed failed rows from ${results.runCode} downloaded',
              kind: EdsToastKind.success,
            ),
          ),
        ],
        if (results.importState == ScraperImportState.importing) ...[
          AppSpacing.gapMd,
          EdsButton.secondary(
            label: 'Cancel import',
            isLoading: isBusy,
            onPressed: () => bloc.add(const AdminScraperImportCancelled()),
          ),
        ] else if (results.importState != ScraperImportState.imported) ...[
          AppSpacing.gapMd,
          EdsButton.secondary(
            label: staged == null
                ? 'Import all to catalogue'
                : 'Import $staged SKUs to catalogue',
            isLoading: isBusy,
            onPressed: () => bloc.add(const AdminScraperImportRequested()),
          ),
        ],
      ],
    );
  }
}
