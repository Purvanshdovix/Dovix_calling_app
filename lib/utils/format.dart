String initials(String name) {
  final parts = name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
  if (parts.isEmpty) return '?';
  final first = parts.first[0];
  final last = parts.length > 1 ? parts.last[0] : '';
  return (first + last).toUpperCase();
}

/// Indian digit grouping: 12480 -> 12,480; 1234567 -> 12,34,567.
String formatNumber(num n) {
  final s = n.round().abs().toString();
  if (s.length <= 3) return n < 0 ? '-$s' : s;
  final last3 = s.substring(s.length - 3);
  var rest = s.substring(0, s.length - 3);
  final groups = <String>[];
  while (rest.length > 2) {
    groups.insert(0, rest.substring(rest.length - 2));
    rest = rest.substring(0, rest.length - 2);
  }
  if (rest.isNotEmpty) groups.insert(0, rest);
  return '${n < 0 ? '-' : ''}${groups.join(',')},$last3';
}

String _two(int v) => v.toString().padLeft(2, '0');

String formatTime(DateTime t) {
  final h = t.hour % 12 == 0 ? 12 : t.hour % 12;
  return '${_two(h)}:${_two(t.minute)} ${t.hour >= 12 ? 'PM' : 'AM'}';
}

const _weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
const _months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];

/// "Today" / "Yesterday" / "Tomorrow" / "Wed 21 Oct"
String dayLabel(DateTime t) {
  final now = DateTime.now();
  final a = DateTime(now.year, now.month, now.day);
  final b = DateTime(t.year, t.month, t.day);
  final diff = a.difference(b).inDays;
  if (diff == 0) return 'Today';
  if (diff == 1) return 'Yesterday';
  if (diff == -1) return 'Tomorrow';
  return '${_weekdays[t.weekday - 1]} ${t.day} ${_months[t.month - 1]}';
}

String fullDate(DateTime t) => '${_weekdays[t.weekday - 1]}, ${t.day} ${_months[t.month - 1]} ${t.year}';

/// Time for today, otherwise the day label.
String shortStamp(DateTime? t) {
  if (t == null) return '—';
  final d = dayLabel(t);
  return d == 'Today' ? formatTime(t) : d;
}

String dayAndTime(DateTime t) => '${dayLabel(t)}, ${formatTime(t)}';

String formatDuration(Duration d) => '${_two(d.inHours)}:${_two(d.inMinutes % 60)}:${_two(d.inSeconds % 60)}';

String formatTalk(int secs) => '${secs ~/ 60}m ${_two(secs % 60)}s';

String greeting() {
  final h = DateTime.now().hour;
  if (h < 12) return 'Good Morning';
  if (h < 17) return 'Good Afternoon';
  return 'Good Evening';
}

/// Case-insensitive search across fields; spaces are ignored so phone numbers match either way.
bool matchesQuery(List<String> fields, String q) {
  final needle = q.toLowerCase().replaceAll(' ', '');
  if (needle.isEmpty) return true;
  return fields.any((f) => f.toLowerCase().replaceAll(' ', '').contains(needle));
}
