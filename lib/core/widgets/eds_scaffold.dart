import 'package:flutter/material.dart';

import '../theme/theme.dart';
import 'eds_app_bar.dart';

/// Standard screen layout: [EdsAppBar], padded scrollable body, an optional
/// sticky action area above an optional bottom navigation bar.
class EdsScaffold extends StatelessWidget {
  const EdsScaffold({
    super.key,
    required this.title,
    required this.body,
    this.leading = EdsAppBarLeading.back,
    this.onBack,
    this.bottomAction,
    this.bottomNav,
    this.scrollable = true,
    this.padding = AppSpacing.screenPadding,
    this.locked = false,
    this.onLogout,
    this.header,
    this.background,
    this.appBar,
  });

  /// Replaces the standard [EdsAppBar]: a tab root with its own header.
  final PreferredSizeWidget? appBar;

  /// Page color; defaults to the theme's white. [AppColors.canvas] makes
  /// white cards stand out (account and detail screens).
  final Color? background;

  final String title;
  final EdsAppBarLeading leading;
  final VoidCallback? onBack;
  final Widget body;

  /// Usually a single `EdsButton` or a `Column` of buttons.
  final Widget? bottomAction;

  /// Usually an `EdsBottomNav`.
  final Widget? bottomNav;

  /// Wrap [body] in a scroll view. Disable for screens that manage
  /// their own scrolling (e.g. `ListView`) or need to fill the viewport.
  final bool scrollable;
  final EdgeInsetsGeometry padding;

  /// An onboarding step the user must finish: no back button, no bottom
  /// navigation and system back does nothing, so the screen's own action
  /// is the only way on.
  final bool locked;

  /// "Log out" in the app bar; locked screens should offer it so the user
  /// isn't stuck.
  final VoidCallback? onLogout;

  /// Fixed above the body, e.g. the onboarding stepper.
  final Widget? header;

  @override
  Widget build(BuildContext context) {
    final content = scrollable
        ? SingleChildScrollView(padding: padding, child: body)
        : Padding(padding: padding, child: body);

    final nav = locked ? null : bottomNav;
    return PopScope(
      canPop: !locked,
      child: Scaffold(
        backgroundColor: background,
        appBar:
            appBar ??
            EdsAppBar(
              title: title,
              leading: locked ? EdsAppBarLeading.brand : leading,
              onBack: onBack,
              onLogout: onLogout,
            ),
        body: header == null
            ? content
            : Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.lg,
                      AppSpacing.md,
                      AppSpacing.lg,
                      AppSpacing.md,
                    ),
                    child: header,
                  ),
                  Divider(height: 1, color: AppColors.border),
                  Expanded(child: content),
                ],
              ),
        bottomNavigationBar: bottomAction == null && nav == null
            ? null
            : Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (bottomAction != null)
                    EdsBottomActionBar(child: bottomAction!),
                  ?nav,
                ],
              ),
      ),
    );
  }
}

/// White sticky footer that hosts the primary call to action.
class EdsBottomActionBar extends StatelessWidget {
  const EdsBottomActionBar({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: SafeArea(top: false, child: child),
    );
  }
}
