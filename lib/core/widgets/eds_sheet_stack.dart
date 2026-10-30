import 'package:flutter/material.dart';

import '../theme/theme.dart';

/// Opens a tall modal sheet that holds a stack of pages: [root], and the
/// pages it pushes on top of itself, each with a back button. [height] is
/// the sheet's exact height, so it can line up with a card on the screen
/// behind it.
Future<void> showEdsSheetStack({
  required BuildContext context,
  required double height,
  required WidgetBuilder root,
}) => showModalBottomSheet<void>(
  context: context,
  isScrollControlled: true,
  useSafeArea: false,
  backgroundColor: AppColors.canvas,
  shape: const RoundedRectangleBorder(
    borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.sheet)),
  ),
  clipBehavior: Clip.antiAlias,
  constraints: BoxConstraints.tightFor(height: height),
  builder: (_) => _EdsSheetStack(root: root),
);

/// What a page inside an [showEdsSheetStack] sheet can do: push another
/// page on top of itself, or close the whole sheet.
class EdsSheetScope extends InheritedWidget {
  const EdsSheetScope({
    super.key,
    required this.push,
    required this.close,
    required super.child,
  });

  final void Function(Widget page) push;
  final VoidCallback close;

  static EdsSheetScope of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<EdsSheetScope>()!;

  @override
  bool updateShouldNotify(EdsSheetScope oldWidget) => false;
}

class _EdsSheetStack extends StatefulWidget {
  const _EdsSheetStack({required this.root});

  final WidgetBuilder root;

  @override
  State<_EdsSheetStack> createState() => _EdsSheetStackState();
}

class _EdsSheetStackState extends State<_EdsSheetStack> {
  final _pages = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    // The navigator the sheet itself is on; popping it closes the sheet.
    final sheet = Navigator.of(context);
    return PopScope(
      canPop: false,
      // Back closes the top page first, then the sheet.
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        final pages = _pages.currentState!;
        if (pages.canPop()) {
          pages.pop();
        } else {
          sheet.pop();
        }
      },
      child: EdsSheetScope(
        push: (page) => _pages.currentState!.push(
          MaterialPageRoute<void>(builder: (_) => page),
        ),
        close: () => sheet.pop(),
        child: Navigator(
          key: _pages,
          onGenerateInitialRoutes: (_, _) => [
            MaterialPageRoute<void>(builder: widget.root),
          ],
        ),
      ),
    );
  }
}

/// One page of an [showEdsSheetStack] sheet: the handle, a header with the
/// [title] (or a custom [header]), a back button on pushed pages and a
/// close button; then the [body] with the screen padding and an optional
/// [bottom] action.
class EdsSheetPage extends StatelessWidget {
  const EdsSheetPage({
    super.key,
    required this.title,
    required this.body,
    this.header,
    this.bottom,
    this.scrollable = true,
    this.busy = false,
  });

  final String title;

  /// Replaces the title line, e.g. a centred name over a type.
  final Widget? header;
  final Widget body;
  final Widget? bottom;

  /// False for a loading or error view that should fill the page.
  final bool scrollable;

  /// A quiet progress line under the header while something saves.
  final bool busy;

  @override
  Widget build(BuildContext context) {
    final pages = Navigator.of(context);
    final sheet = EdsSheetScope.of(context);
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    final padding = EdgeInsets.fromLTRB(
      AppSpacing.lg,
      AppSpacing.md,
      AppSpacing.lg,
      bottom == null ? AppSpacing.xxl + bottomInset : AppSpacing.lg,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppSpacing.gapSm,
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
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.xs,
            AppSpacing.sm,
            AppSpacing.xs,
            0,
          ),
          child: Row(
            children: [
              SizedBox.square(
                dimension: 48,
                child: pages.canPop()
                    ? IconButton(
                        tooltip: 'Back',
                        icon: const Icon(Icons.arrow_back),
                        color: AppColors.ink,
                        onPressed: () => pages.pop(),
                      )
                    : null,
              ),
              Expanded(
                child:
                    header ??
                    Text(
                      title,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.sectionTitle,
                    ),
              ),
              SizedBox.square(
                dimension: 48,
                child: IconButton(
                  tooltip: 'Close',
                  icon: const Icon(Icons.close),
                  color: AppColors.ink,
                  onPressed: sheet.close,
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 2,
          child: busy
              ? LinearProgressIndicator(
                  minHeight: 2,
                  color: AppColors.crimson,
                  backgroundColor: AppColors.primaryTint,
                )
              : null,
        ),
        Expanded(
          child: scrollable
              ? SingleChildScrollView(padding: padding, child: body)
              : Padding(padding: padding, child: body),
        ),
        if (bottom != null)
          Padding(
            padding: EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.sm,
              AppSpacing.lg,
              AppSpacing.lg + bottomInset,
            ),
            child: bottom,
          ),
      ],
    );
  }
}
