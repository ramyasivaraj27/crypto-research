import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// Full offline cache: every successful fetch is saved with a timestamp;
/// on failure the screens fall back to the saved copy + "offline" badge.
class CacheStore {
  static const _prefix = 'cache:';

  Future<void> save(String key, Object value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('$_prefix$key', jsonEncode({'saved_at': DateTime.now().toIso8601String(), 'data': value}));
  }

  Future<({dynamic data, DateTime? savedAt})> load(String key) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('$_prefix$key');
    if (raw == null) return (data: null, savedAt: null);
    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      return (data: map['data'], savedAt: DateTime.tryParse(map['saved_at']?.toString() ?? ''));
    } catch (_) {
      return (data: null, savedAt: null);
    }
  }
}
