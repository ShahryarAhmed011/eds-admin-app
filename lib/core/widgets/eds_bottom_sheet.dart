import 'package:flutter/material.dart';

import '../theme/theme.dart';

/// Shows a modal sheet with the standard handle, title and subtitle.
Future<T?> showEdsBottomSheet<T>({
  required BuildContext context,
  required String title,
  String? subtitle,
  required WidgetBuilder builder,
}) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (context) => EdsBottomSheet(
      title: title,
      subtitle: subtitle,
      child: builder(context),
    ),
  );
}

/// Sheet body layout. Usable directly when embedding a sheet in a page.
class EdsBottomSheet extends StatelessWidget {
  const EdsBottomSheet({
    super.key,
    required this.title,
    required this.child,
    this.subtitle,
  });

  final String title;
  final String? subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.md,
          AppSpacing.lg,
          AppSpacing.lg,
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: AppRadius.pillAll,
                  ),
                ),
              ),
              AppSpacing.gapXl,
              Text(title, style: AppTextStyles.sectionTitle),
              if (subtitle != null) ...[
                const SizedBox(height: AppSpacing.xxs),
                Text(subtitle!, style: AppTextStyles.bodySecondary),
              ],
              AppSpacing.gapLg,
              child,
            ],
          ),
        ),
      ),
    );
  }
}
