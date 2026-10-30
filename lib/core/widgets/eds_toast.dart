import 'package:flutter/material.dart';

import '../theme/theme.dart';

/// What a toast reports; only the icon changes.
enum EdsToastKind { info, success, error }

/// The app's only toast: a rounded card with a Crimson border on a light
/// Crimson background that slides down from the top, stays a few seconds
/// and slides away. Tap or swipe it up to dismiss. One at a time: a new
/// toast replaces the one showing.
///
/// ```dart
/// EdsToast.show(context, 'Address saved', kind: EdsToastKind.success);
///
/// // Before leaving the screen, keep a handle and show after:
/// final toast = EdsToast.of(context);
/// context.pop();
/// toast.show('Shop approved');
/// ```
abstract final class EdsToast {
  static void show(
    BuildContext context,
    String message, {
    EdsToastKind kind = EdsToastKind.info,
  }) => of(context).show(message, kind: kind);

  /// A handle that keeps working after [context] is gone.
  static EdsToaster of(BuildContext context) =>
      EdsToaster._(Overlay.of(context, rootOverlay: true));
}

class EdsToaster {
  EdsToaster._(this._overlay);

  final OverlayState _overlay;

  static OverlayEntry? _current;

  void show(String message, {EdsToastKind kind = EdsToastKind.info}) {
    if (!_overlay.mounted) return;
    _current?.remove();
    late final OverlayEntry entry;
    entry = OverlayEntry(
      builder: (_) => _Toast(
        message: message,
        kind: kind,
        onDone: () {
          if (_current == entry) _current = null;
          if (entry.mounted) entry.remove();
        },
      ),
    );
    _current = entry;
    _overlay.insert(entry);
  }
}

class _Toast extends StatefulWidget {
  const _Toast({
    required this.message,
    required this.kind,
    required this.onDone,
  });

  final String message;
  final EdsToastKind kind;
  final VoidCallback onDone;

  @override
  State<_Toast> createState() => _ToastState();
}

class _ToastState extends State<_Toast> with SingleTickerProviderStateMixin {
  // One controller covers slide in, the visible time and slide out, so no
  // timer is left running.
  static const _total = Duration(milliseconds: 3500);
  static const _slideShare = 0.08;

  late final AnimationController _controller =
      AnimationController(vsync: this, duration: _total)
        ..addStatusListener((status) {
          if (status == AnimationStatus.completed) widget.onDone();
        })
        ..forward();

  /// 0 hidden → 1 shown → 0 hidden over the controller's run.
  late final Animation<double> _shown = TweenSequence<double>([
    TweenSequenceItem(
      tween: Tween(
        begin: 0.0,
        end: 1.0,
      ).chain(CurveTween(curve: Curves.easeOutCubic)),
      weight: _slideShare,
    ),
    TweenSequenceItem(tween: ConstantTween(1), weight: 1 - 2 * _slideShare),
    TweenSequenceItem(
      tween: Tween(
        begin: 1.0,
        end: 0.0,
      ).chain(CurveTween(curve: Curves.easeInCubic)),
      weight: _slideShare,
    ),
  ]).animate(_controller);

  void _dismiss() {
    const outStart = 1 - _slideShare;
    if (_controller.value < outStart) _controller.value = outStart;
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final icon = switch (widget.kind) {
      EdsToastKind.info => Icons.info_outline,
      EdsToastKind.success => Icons.check_circle_outline,
      EdsToastKind.error => Icons.error_outline,
    };
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.sm,
            AppSpacing.lg,
            0,
          ),
          child: AnimatedBuilder(
            animation: _shown,
            builder: (context, child) => FractionalTranslation(
              translation: Offset(0, -1.3 * (1 - _shown.value)),
              child: Opacity(opacity: _shown.value, child: child),
            ),
            child: Semantics(
              liveRegion: true,
              child: GestureDetector(
                onTap: _dismiss,
                onVerticalDragEnd: (details) {
                  if ((details.primaryVelocity ?? 0) < 0) _dismiss();
                },
                child: Material(
                  color: AppColors.toastBackground,
                  shape: RoundedRectangleBorder(
                    borderRadius: AppRadius.mdAll,
                    side: const BorderSide(color: AppColors.crimson),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.md,
                    ),
                    child: Row(
                      children: [
                        Icon(
                          icon,
                          size: AppSizes.icon,
                          color: AppColors.crimson,
                        ),
                        AppSpacing.gapMd,
                        Expanded(
                          child: Text(
                            widget.message,
                            style: AppTextStyles.itemTitle,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
