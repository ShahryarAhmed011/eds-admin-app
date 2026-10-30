import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// `EdsToast` is the app's only toast: no screen may show a Material
/// SnackBar.
void main() {
  test('no SnackBar outside EdsToast', () {
    final pattern = RegExp(r'\b(SnackBar|ScaffoldMessenger)\b');
    final violations = <String>[];
    for (final file in Directory('lib').listSync(recursive: true)) {
      if (file is! File || !file.path.endsWith('.dart')) continue;
      final lines = file.readAsLinesSync();
      for (var i = 0; i < lines.length; i++) {
        if (pattern.hasMatch(lines[i])) {
          violations.add('${file.path}:${i + 1}');
        }
      }
    }
    expect(violations, isEmpty, reason: violations.join('\n'));
  });
}
