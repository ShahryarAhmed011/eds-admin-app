import 'package:flutter/material.dart';

import '../../../../../core/core.dart';

/// Card with a bold heading followed by plain fact lines and an optional
/// muted footnote ("SKU-001 · Active variant", "Last run · SCR-041").
/// Shared by the catalogue, product request and scraper screens.
class AdminFactCard extends StatelessWidget {
  const AdminFactCard({
    super.key,
    required this.title,
    required this.lines,
    this.footnote,
    this.largeTitle = false,
  });

  final String title;
  final List<String> lines;
  final String? footnote;

  /// Use the section title style for the heading.
  final bool largeTitle;

  @override
  Widget build(BuildContext context) {
    return EdsCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: largeTitle
                ? AppTextStyles.sectionTitle
                : AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.w700),
          ),
          for (final line in lines) ...[
            AppSpacing.gapMd,
            Text(line, style: AppTextStyles.bodyLarge),
          ],
          if (footnote != null) ...[
            AppSpacing.gapMd,
            Text(footnote!, style: AppTextStyles.bodySecondary),
          ],
        ],
      ),
    );
  }
}
