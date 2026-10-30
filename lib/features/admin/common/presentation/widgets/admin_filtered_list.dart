import 'package:flutter/material.dart';

import '../../../../../core/core.dart';

/// Admin list layout: search, filter tabs, counted heading, a card of
/// [AdminRecordTile]s and an optional footer note.
/// Used by the KYC review, users and shops lists.
class AdminFilteredList extends StatelessWidget {
  const AdminFilteredList({
    super.key,
    required this.searchHint,
    required this.tabLabels,
    required this.selectedTab,
    required this.onTabChanged,
    required this.title,
    required this.children,
    this.subtitle,
    this.onSearchChanged,
    this.footer,
    this.emptyMessage = 'No records match your search.',
  });

  final String searchHint;
  final ValueChanged<String>? onSearchChanged;
  final List<String> tabLabels;
  final int selectedTab;
  final ValueChanged<int> onTabChanged;
  final String title;
  final String? subtitle;
  final List<Widget> children;
  final Widget? footer;
  final String emptyMessage;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        EdsSearchField(hint: searchHint, onChanged: onSearchChanged),
        AppSpacing.gapLg,
        EdsSegmentedTabs(
          labels: tabLabels,
          selectedIndex: selectedTab,
          onChanged: onTabChanged,
        ),
        AppSpacing.gapXl,
        EdsSectionHeader(title: title, subtitle: subtitle),
        AppSpacing.gapLg,
        if (children.isEmpty)
          EdsCard(child: Text(emptyMessage, style: AppTextStyles.bodySecondary))
        else
          EdsGroupCard(children: children),
        if (footer != null) ...[AppSpacing.gapLg, footer!],
      ],
    );
  }
}

/// Letter avatar + name + meta line + status badge, as used in admin lists.
class AdminRecordTile extends StatelessWidget {
  const AdminRecordTile({
    super.key,
    required this.title,
    required this.subtitle,
    this.badge,
    this.badgeTone = EdsTone.success,
    this.onTap,
    this.showChevron = false,
  });

  final String title;
  final String subtitle;
  final String? badge;
  final EdsTone badgeTone;
  final VoidCallback? onTap;
  final bool showChevron;

  @override
  Widget build(BuildContext context) {
    return EdsListTile(
      leading: EdsAvatar(text: title),
      title: title,
      titleStyle: AppTextStyles.itemTitleLarge,
      subtitle: subtitle,
      trailing: badge == null ? null : EdsBadge(badge!, tone: badgeTone),
      showChevron: showChevron,
      onTap: onTap,
    );
  }
}
