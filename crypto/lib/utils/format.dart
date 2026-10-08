import 'package:intl/intl.dart';

final _usd0 = NumberFormat.currency(symbol: '\$', decimalDigits: 2);
final _usdFull = NumberFormat.currency(symbol: '\$', decimalDigits: 0);
final _compact = NumberFormat.compactCurrency(symbol: '\$', decimalDigits: 2);

String fmtPrice(double? v) {
  if (v == null) return '—';
  if (v < 1) return '\$${v.toStringAsFixed(4)}';
  if (v < 1000) return _usd0.format(v);
  return _usdFull.format(v);
}

String fmtCompact(double? v) => v == null ? '—' : _compact.format(v);

String fmtPct(double? v) {
  if (v == null) return '—';
  final sign = v >= 0 ? '+' : '';
  return '$sign${v.toStringAsFixed(2)}%';
}

String fmtSupply(double? v) {
  if (v == null) return '—';
  return NumberFormat.compact().format(v);
}

String fmtAgo(DateTime? t) {
  if (t == null) return 'unknown time';
  final d = DateTime.now().difference(t);
  if (d.inMinutes < 1) return 'just now';
  if (d.inMinutes < 60) return '${d.inMinutes}m ago';
  if (d.inHours < 24) return '${d.inHours}h ago';
  return '${d.inDays}d ago';
}
