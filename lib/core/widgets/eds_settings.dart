import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../theme/theme.dart';

/// A titled group of [EdsSettingsTile]s on one card, with hairlines
/// between the rows. The quiet, premium list used by account screens.
class EdsSettingsSection extends StatelessWidget {
  const EdsSettingsSection({super.key, this.title, required this.children});

  /// Small uppercase label above the card.
  final String? title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (title != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.xs,
              0,
              AppSpacing.xs,
              AppSpacing.sm,
            ),
            child: Text(title!.toUpperCase(), style: AppTextStyles.eyebrow),
          ),
        DecoratedBox(
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: AppRadius.mdAll,
            border: Border.all(color: AppColors.border),
          ),
          child: ClipRRect(
            borderRadius: AppRadius.mdAll,
            child: Material(
              color: AppColors.none,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (var i = 0; i < children.length; i++) ...[
                    if (i > 0)
                      Divider(
                        height: 1,
                        thickness: 1,
                        indent: AppSpacing.lg,
                        color: AppColors.border,
                      ),
                    children[i],
                  ],
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// The quiet pencil at the end of an editable row. The row itself is the
/// tap target, so this is a glyph, not a button.
class EdsEditGlyph extends StatelessWidget {
  const EdsEditGlyph({super.key});

  @override
  Widget build(BuildContext context) {
    return Icon(Icons.edit_outlined, size: 16, color: AppColors.chevron);
  }
}

/// One row of an [EdsSettingsSection]: icon chip, title, an optional
/// secondary line, an optional trailing widget, and either a per-field edit
/// pencil ([onEdit]) or a chevron when tappable.
class EdsSettingsTile extends StatelessWidget {
  const EdsSettingsTile({
    super.key,
    required this.title,
    this.icon,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.onEdit,
    this.destructive = false,
    this.maxSubtitleLines = 1,
  });

  final String title;
  final IconData? icon;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  /// When set, a quiet pencil replaces the chevron and, unless [onTap] is
  /// given, tapping the row edits the field.
  final VoidCallback? onEdit;

  /// Crimson title and icon, no chevron (e.g. "Sign out").
  final bool destructive;
  final int maxSubtitleLines;

  @override
  Widget build(BuildContext context) {
    final accent = destructive ? AppColors.crimson : AppColors.ink;
    return InkWell(
      onTap: onTap ?? onEdit,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 56),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          child: Row(
            children: [
              if (icon != null) ...[
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: destructive
                        ? AppColors.primaryTint
                        : AppColors.sectionBackground,
                    borderRadius: AppRadius.smAll,
                  ),
                  child: Icon(icon, size: 18, color: accent),
                ),
                AppSpacing.gapMd,
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: AppTextStyles.itemTitle.copyWith(color: accent),
                    ),
                    if (subtitle != null && subtitle!.isNotEmpty) ...[
                      const SizedBox(height: AppSpacing.xxs),
                      Text(
                        subtitle!,
                        maxLines: maxSubtitleLines,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.bodySecondary,
                      ),
                    ],
                  ],
                ),
              ),
              if (trailing != null) ...[AppSpacing.gapSm, trailing!],
              if (onEdit != null) ...[
                AppSpacing.gapSm,
                const EdsEditGlyph(),
              ] else if (onTap != null && !destructive) ...[
                AppSpacing.gapXs,
                Icon(Icons.chevron_right, size: 20, color: AppColors.chevron),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Centered identity block: a round photo (or initials / icon), the name,
/// a few quiet lines and an optional badge underneath.
class EdsIdentityHeader extends StatelessWidget {
  const EdsIdentityHeader({
    super.key,
    required this.name,
    this.photo,
    this.icon,
    this.lines = const [],
    this.verified = false,
    this.badge,
    this.action,
    this.onPhotoTap,
    this.photoBusy = false,
  });

  /// Makes the photo tappable and adds a camera badge (change photo).
  final VoidCallback? onPhotoTap;

  /// A spinner over the photo while it uploads.
  final bool photoBusy;

  final String name;
  final Uint8List? photo;

  /// Shown instead of initials when there's no photo (e.g. a shop).
  final IconData? icon;
  final List<String> lines;

  /// A crimson tick next to the name.
  final bool verified;
  final Widget? badge;

  /// Small pill under everything, e.g. "Edit profile".
  final Widget? action;

  static const _size = 88.0;

  String get _initials => name
      .split(RegExp(r'\s+'))
      .where((part) => part.isNotEmpty)
      .take(2)
      .map((part) => part[0].toUpperCase())
      .join();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Semantics(
          button: onPhotoTap != null,
          label: onPhotoTap == null ? null : 'Change profile photo',
          child: GestureDetector(
            onTap: onPhotoTap,
            child: Stack(
              children: [
                Container(
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.primaryTint, width: 2),
                  ),
                  child: Container(
                    width: _size,
                    height: _size,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AppColors.primaryTint,
                      shape: BoxShape.circle,
                      image: photo == null
                          ? null
                          : DecorationImage(
                              image: MemoryImage(photo!),
                              fit: BoxFit.cover,
                            ),
                    ),
                    child: photo != null
                        ? null
                        : icon != null
                        ? Icon(icon, size: 36, color: AppColors.crimson)
                        : Text(
                            _initials,
                            style: AppTextStyles.headline.copyWith(
                              color: AppColors.crimson,
                            ),
                          ),
                  ),
                ),
                if (photoBusy)
                  Positioned.fill(
                    child: Padding(
                      padding: const EdgeInsets.all(5),
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: AppColors.scrim,
                          shape: BoxShape.circle,
                        ),
                        child: const Center(
                          child: SizedBox.square(
                            dimension: 26,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: AppColors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                if (onPhotoTap != null || photoBusy)
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: AppColors.crimson,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.white, width: 2),
                      ),
                      child: const Icon(
                        Icons.photo_camera_outlined,
                        size: 16,
                        color: AppColors.white,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
        AppSpacing.gapLg,
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: Text(
                name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.title,
              ),
            ),
            if (verified) ...[
              AppSpacing.gapXs,
              const Icon(Icons.verified, size: 20, color: AppColors.crimson),
            ],
          ],
        ),
        for (final line in lines) ...[
          const SizedBox(height: AppSpacing.xxs),
          Text(
            line,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: AppTextStyles.bodySecondary,
          ),
        ],
        if (badge != null) ...[AppSpacing.gapMd, badge!],
        if (action != null) ...[AppSpacing.gapMd, action!],
      ],
    );
  }
}

/// Small outlined pill button, e.g. "Edit profile" under a header.
class EdsPillButton extends StatelessWidget {
  const EdsPillButton({
    super.key,
    required this.label,
    required this.onTap,
    this.icon,
  });

  final String label;
  final IconData? icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.white,
      shape: RoundedRectangleBorder(
        borderRadius: AppRadius.pillAll,
        side: BorderSide(color: AppColors.border),
      ),
      child: InkWell(
        customBorder: const StadiumBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.sm,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 16, color: AppColors.crimson),
                AppSpacing.gapXs,
              ],
              Text(label, style: AppTextStyles.itemTitle),
            ],
          ),
        ),
      ),
    );
  }
}

/// A row for an [EdsSettingsSection]: label on the left, value on the right.
class EdsDetailRow extends StatelessWidget {
  const EdsDetailRow(
    this.label,
    this.value, {
    super.key,
    this.onEdit,
    this.valueIcon,
    this.valueColor,
    this.labelWidth,
    this.maxLines = 1,
  });

  final String label;
  final String value;

  /// Lines the value may wrap to before it ellipsises; past one, the label
  /// and pencil sit on the first line.
  final int maxLines;

  /// When set, the row is tappable and ends in a quiet pencil.
  final VoidCallback? onEdit;

  /// A small glyph before the value, and a colour for both (e.g. a green
  /// tick and "Verified"); the value stays in the row's style otherwise.
  final IconData? valueIcon;
  final Color? valueColor;

  /// With a width, the label is a fixed column and the value starts right
  /// after it (a form-like list); otherwise the value sits at the far end.
  final double? labelWidth;

  @override
  Widget build(BuildContext context) {
    final aligned = labelWidth != null;
    final row = Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      child: Row(
        crossAxisAlignment: maxLines > 1
            ? CrossAxisAlignment.start
            : CrossAxisAlignment.center,
        children: [
          if (aligned)
            SizedBox(
              width: labelWidth,
              child: Text(label, style: AppTextStyles.bodySecondary),
            )
          else ...[
            Text(label, style: AppTextStyles.bodySecondary),
            AppSpacing.gapLg,
          ],
          Expanded(
            child: Row(
              mainAxisAlignment: aligned
                  ? MainAxisAlignment.start
                  : MainAxisAlignment.end,
              children: [
                if (valueIcon != null) ...[
                  Icon(valueIcon, size: 16, color: valueColor),
                  AppSpacing.gapXs,
                ],
                Flexible(
                  child: Text(
                    value,
                    textAlign: aligned ? TextAlign.start : TextAlign.end,
                    maxLines: maxLines,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.itemTitle.copyWith(color: valueColor),
                  ),
                ),
              ],
            ),
          ),
          if (onEdit != null) ...[AppSpacing.gapSm, const EdsEditGlyph()],
        ],
      ),
    );
    return onEdit == null ? row : InkWell(onTap: onEdit, child: row);
  }
}
