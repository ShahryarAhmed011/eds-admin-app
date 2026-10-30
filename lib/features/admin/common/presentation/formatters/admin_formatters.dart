/// Small, dependency-free formatters for admin screens (no `intl`).
abstract final class AdminFormat {
  static const _months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', //
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

  /// "9:30 am".
  static String time(DateTime t) {
    final local = t.toLocal();
    final hour = local.hour % 12 == 0 ? 12 : local.hour % 12;
    final minute = local.minute.toString().padLeft(2, '0');
    return '$hour:$minute ${local.hour < 12 ? 'am' : 'pm'}';
  }

  /// "02 Sep".
  static String dayMonth(DateTime t) {
    final local = t.toLocal();
    return '${local.day.toString().padLeft(2, '0')} ${_months[local.month - 1]}';
  }

  /// "16 Oct 2026".
  static String date(DateTime t) => '${dayMonth(t)} ${t.toLocal().year}';

  /// "9:30 am" today, otherwise "15 Oct, 7:40 am".
  static String dateTime(DateTime t, {DateTime? now}) {
    final n = (now ?? DateTime.now()).toLocal();
    final local = t.toLocal();
    final sameDay =
        local.year == n.year && local.month == n.month && local.day == n.day;
    return sameDay ? time(local) : '${dayMonth(local)}, ${time(local)}';
  }

  /// Compact age: "6 min", "26h", "3d".
  static String age(DateTime since, {DateTime? now}) {
    final d = (now ?? DateTime.now()).difference(since);
    if (d.inMinutes < 1) return 'just now';
    if (d.inMinutes < 60) return '${d.inMinutes} min';
    if (d.inHours < 48) return '${d.inHours}h';
    return '${d.inDays}d';
  }

  /// "kyc_under_review" → "Kyc under review".
  static String humanize(String raw) {
    final text = raw.replaceAll(RegExp(r'[_\-]+'), ' ').trim();
    if (text.isEmpty) return 'Unknown';
    return text[0].toUpperCase() + text.substring(1);
  }
}
