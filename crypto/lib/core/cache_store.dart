import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// Full offline cache: every successful fetch is saved with a timestamp;
/// on failure the screens fall back to the saved copy + "offline" badge.
///
/// Keys are namespaced by [_schemaVersion]: bump it whenever a cached JSON
/// shape changes so old entries from previous builds are never parsed.
class CacheStore {
  static const _prefix = 'cache:';
  static const _schemaVersion = 'v2';

  String _key(String key) => '$_prefix$_schemaVersion:$key';

  Future<void> save(String key, Object value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key(key), jsonEncode({'saved_at': DateTime.now().toIso8601String(), 'data': value}));
  }

  Future<({dynamic data, DateTime? savedAt})> load(String key) async {    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key(key));
    if (raw == null) return (data: null, savedAt: null);
    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      return (data: map['data'], savedAt: DateTime.tryParse(map['saved_at']?.toString() ?? ''));
    } catch (_) {
      return (data: null, savedAt: null);
    }
  }

  /// Wipes all cached market data (used by Settings).
  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    for (final k in prefs.getKeys().where((k) => k.startsWith(_prefix))) {
      await prefs.remove(k);
    }
  }
}
