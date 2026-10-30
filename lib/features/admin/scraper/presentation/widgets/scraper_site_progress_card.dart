import 'package:flutter/material.dart';

import '../../../../../core/core.dart';
import '../../domain/entities/scraper.dart';

/// Card with a site's name, percentage, progress bar and fetch status.
class ScraperSiteProgressCard extends StatelessWidget {
  const ScraperSiteProgressCard({super.key, required this.site});

  final ScraperSource site;

  String? get _caption {
    final (fetched, total) = (site.fetchedRows, site.totalRows);
    if (site.isComplete) {
      return fetched == null
          ? 'Completed'
          : '$fetched rows fetched · Completed';
    }
    final page = site.currentPage == null
        ? null
        : 'Fetching page ${site.currentPage}'
              '${site.totalPages == null ? '' : ' of ${site.totalPages}'}';
    final rows = fetched == null
        ? null
        : total == null
        ? '$fetched rows'
        : '$fetched of $total rows';
    final parts = [?rows, ?page];
    return parts.isEmpty ? null : parts.join(' · ');
  }

  @override
  Widget build(BuildContext context) {
    final caption = _caption;
    return EdsCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  site.name,
                  style: AppTextStyles.bodyLarge.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Text(
                '${site.displayPercent}%',
                style: AppTextStyles.link.copyWith(
                  fontSize: AppTextStyles.bodyLarge.fontSize,
                ),
              ),
            ],
          ),
          AppSpacing.gapMd,
          EdsProgressBar(value: site.fraction),
          if (caption != null) ...[
            AppSpacing.gapMd,
            Text(caption, style: AppTextStyles.bodySecondary),
          ],
        ],
      ),
    );
  }
}
