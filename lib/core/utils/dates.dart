const _months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];

/// "10 Oct" (adds the year when it is not the current year).
String formatShortDate(DateTime d, {DateTime? now}) {
  final today = now ?? DateTime.now();
  final base = '${d.day} ${_months[d.month - 1]}';
  return d.year == today.year ? base : '$base ${d.year}';
}

/// "Just now", "5 min ago", "3 h ago", "Yesterday", or a short date.
String formatRelative(DateTime when, {DateTime? now}) {
  final current = now ?? DateTime.now();
  final diff = current.difference(when);
  if (diff.inMinutes < 1) return 'Just now';
  if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
  if (diff.inHours < 24 && current.day == when.day) return '${diff.inHours} h ago';
  final yesterday = DateTime(current.year, current.month, current.day).subtract(const Duration(days: 1));
  if (DateTime(when.year, when.month, when.day) == yesterday) return 'Yesterday';
  return formatShortDate(when, now: current);
}

String greetingFor(DateTime now) {
  if (now.hour < 12) return 'Good morning';
  if (now.hour < 17) return 'Good afternoon';
  return 'Good evening';
}

const _longMonths = [
  'January', 'February', 'March', 'April', 'May', 'June',
  'July', 'August', 'September', 'October', 'November', 'December',
];
const _weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

/// "October 2026"
String formatMonthYear(DateTime d) => '${_longMonths[d.month - 1]} ${d.year}';

/// "Today", "Yesterday" or "Mon 5 Oct".
String formatDayHeader(DateTime d, {DateTime? now}) {
  final t = now ?? DateTime.now();
  final day = DateTime(d.year, d.month, d.day);
  final today = DateTime(t.year, t.month, t.day);
  if (day == today) return 'Today';
  if (day == today.subtract(const Duration(days: 1))) return 'Yesterday';
  return '${_weekdays[d.weekday - 1]} ${formatShortDate(d, now: t)}';
}
