import 'dart:convert';
import 'dart:typed_data';

/// Tolerant readers for API JSON. The backend sends integer ids today; the
/// app treats every id as an opaque string so a type change can't break it.
typedef Json = Map<String, dynamic>;

extension JsonRead on Json {
  String id([String key = 'id']) => this[key]?.toString() ?? '';

  String? str(String key) => this[key]?.toString();

  String strOr(String key, [String fallback = '']) =>
      this[key]?.toString() ?? fallback;

  int? integer(String key) => switch (this[key]) {
    final int v => v,
    final num v => v.toInt(),
    final String v => int.tryParse(v),
    _ => null,
  };

  double? decimal(String key) => switch (this[key]) {
    final num v => v.toDouble(),
    final String v => double.tryParse(v),
    _ => null,
  };

  bool boolean(String key, [bool fallback = false]) => switch (this[key]) {
    final bool v => v,
    final String v => v == 'true',
    final num v => v != 0,
    _ => fallback,
  };

  DateTime? date(String key) {
    final raw = this[key];
    return raw is String ? DateTime.tryParse(raw) : null;
  }

  /// An image sent inline as base64 (plain, or a `data:image/…;base64,`
  /// URL). Null when absent, `""` (the API's "not set") or not base64.
  Uint8List? bytes(String key) {
    final raw = this[key];
    if (raw is! String || raw.isEmpty) return null;
    final comma = raw.startsWith('data:') ? raw.indexOf(',') : -1;
    try {
      final decoded = base64Decode(raw.substring(comma + 1).trim());
      return decoded.isEmpty ? null : decoded;
    } on FormatException {
      return null;
    }
  }

  Json? obj(String key) {
    final raw = this[key];
    return raw is Map ? raw.cast<String, dynamic>() : null;
  }

  List<Json> objList(String key) {
    final raw = this[key];
    if (raw is! List) return const [];
    return raw.whereType<Map>().map((e) => e.cast<String, dynamic>()).toList();
  }
}
