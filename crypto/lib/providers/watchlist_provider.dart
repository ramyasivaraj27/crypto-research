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

  int page = 1;
  int totalPages = 1;
  bool loadingMore = false;
  String pageError = '';
  static const int pageSize = 20;

  bool get hasNext => page < totalPages;

  Set<int> get starredIds => items.map((c) => c.id).toSet();

  List<Coin> parseItems(List raw) => [
        for (final e in raw)
          if (e is Map) Coin.tryFromJson(e['coin'])
      ].whereType<Coin>().toList();

  Future<void> refresh() async {
    if (!auth.isLoggedIn) return;
    loading = true;
    error = '';
    pageError = '';
    notifyListeners();
    try {
      final res = await api.watchlistItems(page: 1, pageSize: pageSize);
      items = parseItems(res.items);
      page = res.page;
      totalPages = res.totalPages;
      offline = false;
      await cache.save('watchlist', res.items);
      savedAt = DateTime.now();
    } on ApiException catch (e) {
      error = e.message;
      final hit = await cache.load('watchlist');
      if (hit.data != null) {
        items = parseItems(hit.data as List);
        savedAt = hit.savedAt;
        offline = true;
        page = 1;
        totalPages = 1;
      }
    }
    loading = false;
    notifyListeners();
  }

  Future<void> loadMore() async {
    if (loading || loadingMore || !hasNext || offline || !auth.isLoggedIn) return;
    loadingMore = true;
    pageError = '';
    notifyListeners();
    try {
      final res = await api.watchlistItems(page: page + 1, pageSize: pageSize);
      items = [...items, ...parseItems(res.items)];
      page = res.page;
      totalPages = res.totalPages;
      await cache.save('watchlist', [for (final c in items) {'coin': c.toJson()}]);
      savedAt = DateTime.now();
    } on ApiException catch (e) {
      pageError = e.message;
    }
    loadingMore = false;
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
