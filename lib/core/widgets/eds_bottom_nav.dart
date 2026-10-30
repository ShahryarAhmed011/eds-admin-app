import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../navigation/eds_nav_item.dart';
import '../theme/theme.dart';

/// Role bottom navigation. Pass one of `RoleNavs.*` as [items].
///
/// Flat and quiet: a hairline on top, outlined glyphs at rest, and a filled
/// crimson glyph with a short indicator above it for the active tab.
class EdsBottomNav extends StatelessWidget {
  const EdsBottomNav({
    super.key,
    required this.items,
    required this.currentIndex,
    this.onTap,
  });

  final List<EdsNavItem> items;
  final int currentIndex;

  /// Defaults to `context.go(item.route)`.
  final ValueChanged<int>? onTap;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 60,
          child: Row(
            children: [
              for (var i = 0; i < items.length; i++)
                Expanded(
                  child: _NavButton(
                    item: items[i],
                    selected: i == currentIndex,
                    onTap: () {
                      if (i == currentIndex) return;
                      if (onTap != null) {
                        onTap!(i);
                      } else {
                        context.go(items[i].route);
                      }
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  const _NavButton({
    required this.item,
    required this.selected,
    required this.onTap,
  });

  final EdsNavItem item;
  final bool selected;
  final VoidCallback onTap;

  static const _duration = Duration(milliseconds: 220);

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppColors.crimson : AppColors.gray;
    return InkWell(
      onTap: onTap,
      highlightColor: AppColors.none,
      splashColor: AppColors.primaryTint,
      child: Stack(
        children: [
          // Short indicator above the active tab.
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Center(
              child: AnimatedContainer(
                duration: _duration,
                curve: Curves.easeOut,
                width: selected ? 20 : 0,
                height: 2.5,
                decoration: const BoxDecoration(
                  color: AppColors.crimson,
                  borderRadius: AppRadius.pillAll,
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  selected ? (item.selectedIcon ?? item.icon) : item.icon,
                  size: 22,
                  color: color,
                ),
                const SizedBox(height: AppSpacing.xs),
                AnimatedDefaultTextStyle(
                  duration: _duration,
                  style: AppTextStyles.navLabel.copyWith(
                    color: color,
                    fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                  ),
                  child: Text(
                    item.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
