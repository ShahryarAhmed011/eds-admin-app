import 'package:flutter/widgets.dart';

/// Lays out every child and shows only [shown], so it is as tall as the
/// tallest child whichever is visible: a button under it stays put from
/// step to step. Hidden children can't be tapped, focused or read out.
class SameHeightSteps extends StatelessWidget {
  const SameHeightSteps({
    super.key,
    required this.shown,
    required this.children,
  });

  final int shown;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.passthrough,
      children: [
        for (var i = 0; i < children.length; i++)
          ExcludeFocus(
            excluding: i != shown,
            child: Visibility(
              visible: i == shown,
              maintainSize: true,
              maintainAnimation: true,
              maintainState: true,
              child: children[i],
            ),
          ),
      ],
    );
  }
}
