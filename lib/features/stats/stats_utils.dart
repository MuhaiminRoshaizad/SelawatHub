/// Formats an integer with comma separators (e.g. 1234 → "1,234").
String fmtNum(int n) {
  if (n < 1000) return '$n';
  final s = n.toString();
  final b = StringBuffer();
  for (int i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) b.write(',');
    b.write(s[i]);
  }
  return b.toString();
}
