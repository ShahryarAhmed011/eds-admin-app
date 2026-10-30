import 'package:flutter/material.dart';

import '../theme/theme.dart';

/// Thin rounded progress bar. [value] is 0–1.
class EdsProgressBar extends StatelessWidget {
  const EdsProgressBar({super.key, required this.value});

  final double value;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: AppRadius.pillAll,
      child: LinearProgressIndicator(value: value, minHeight: 6),
    );
  }
}
