import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Every color comes from `AppColors`. Only `app_colors.dart` may name a
/// Material color, write a hex value or derive an opacity.
void main() {
  const allowed = 'lib/core/theme/app_colors.dart';
  final forbidden = <String, RegExp>{
    'Colors.*': RegExp(r'(?<![\w.])Colors\.'),
    'raw hex Color': RegExp(r'Color\(\s*0x'),
    'Color.fromARGB/fromRGBO': RegExp(r'Color\.from(ARGB|RGBO)'),
    'opacity helper': RegExp(r'\.(withValues|withOpacity|withAlpha)\('),
    'shadow': RegExp(r'\bBoxShadow\b'),
    'gradient': RegExp(r'\b(Linear|Radial|Sweep)Gradient\b'),
  };

  test('colors are only defined in app_colors.dart', () {
    final violations = <String>[];
    final files = Directory('lib')
        .listSync(recursive: true)
        .whereType<File>()
        .where((f) => f.path.endsWith('.dart') && f.path != allowed);
    for (final file in files) {
      final lines = file.readAsLinesSync();
      for (var i = 0; i < lines.length; i++) {
        for (final MapEntry(:key, :value) in forbidden.entries) {
          if (value.hasMatch(lines[i])) {
            violations.add('${file.path}:${i + 1} $key');
          }
        }
      }
    }
    expect(violations, isEmpty, reason: violations.join('\n'));
  });
}
