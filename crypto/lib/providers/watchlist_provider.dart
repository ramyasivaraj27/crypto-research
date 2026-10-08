import 'package:flutter/foundation.dart';

import '../core/api_client.dart';
import '../core/auth_store.dart';
import '../core/cache_store.dart';
import '../models/market.dart';

/// Watchlist mirrored on-device; works offline after first load.
class WatchlistProvider extends ChangeNotifier {
  final ApiClient api;
  final AuthStore auth;
  final CacheStore cache;
  WatchlistProvider(this.api, this.auth, this.cache);

  bool loading = false;
  String error = '';
  List<Coin> items = [];
  DateTime? savedAt;
  bool offline = false;

  Set<int> get starredIds => items.map((c) => c.id).toSet();

  Future<void> refresh() async {
    if (!auth.isLoggedIn) return;
    loading = true;
    error = '';
    notifyListeners();
    List<Coin> parseItems(List raw) => [
          for (final e in raw)
            if (e is Map) Coin.tryFromJson(e['coin'])
        ].whereType<Coin>().toList();

    try {
      final raw = await api.watchlistItems();
      items = parseItems(raw);
      offline = false;
      await cache.save('watchlist', raw);
      savedAt = DateTime.now();
    } on ApiException catch (e) {
      error = e.message;
      final hit = await cache.load('watchlist');
      if (hit.data != null) {
        items = parseItems(hit.data as List);
        savedAt = hit.savedAt;
        offline = true;
      }
    }
    loading = false;
    notifyListeners();
  }

  Future<void> toggle(int coinId) async {
    try {
      final res = await api.toggleStar(coinId);
      await refresh();
      if (res['starred'] == false) {
        items.removeWhere((c) => c.id == coinId);
        notifyListeners();
      }
    } on ApiException catch (e) {
      error = e.message;
      notifyListeners();
    }
  }
}
