/// Time formatting for admin screens. The admin console always shows
/// Pakistan Standard Time (UTC+5, no daylight saving).
library;

const _months = [
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'May',
  'Jun',
  'Jul',
  'Aug',
  'Sep',
  'Oct',
  'Nov',
  'Dec',
];

/// Converts any instant to wall-clock Pakistan Standard Time.
DateTime toPakistanTime(DateTime instant) =>
    instant.toUtc().add(const Duration(hours: 5));

/// "9:38 am".
String formatAdminTime(DateTime instant) {
  final t = toPakistanTime(instant);
  final hour = t.hour % 12 == 0 ? 12 : t.hour % 12;
  final minute = t.minute.toString().padLeft(2, '0');
  return '$hour:$minute ${t.hour < 12 ? 'am' : 'pm'}';
}

/// "16 Oct".
String formatAdminDay(DateTime instant) {
  final t = toPakistanTime(instant);
  return '${t.day.toString().padLeft(2, '0')} ${_months[t.month - 1]}';
}

/// "16 Oct 2026".
String formatAdminDate(DateTime instant) =>
    '${formatAdminDay(instant)} ${toPakistanTime(instant).year}';

/// "16 Oct, 9:10 am".
String formatAdminDayTime(DateTime instant) =>
    '${formatAdminDay(instant)}, ${formatAdminTime(instant)}';

/// Same calendar day in Pakistan Standard Time.
bool isSameAdminDay(DateTime a, DateTime b) {
  final (x, y) = (toPakistanTime(a), toPakistanTime(b));
  return x.year == y.year && x.month == y.month && x.day == y.day;
}
