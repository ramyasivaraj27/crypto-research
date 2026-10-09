import 'dart:async';

import 'package:flutter/foundation.dart';

import '../core/api_client.dart';
import '../core/cache_store.dart';
import '../models/market.dart';

enum LoadState { idle, loading, loaded, empty, error }

/// Coin list with search/filter/sort + offline cache fallback.
class MarketProvider extends ChangeNotifier {
  final ApiClient api;
  final CacheStore cache;
  MarketProvider(this.api, this.cache);

  LoadState state = LoadState.idle;
  String error = '';
  List<Coin> coins = [];
  DateTime? savedAt;
  bool offline = false;
  String search = '';
  String ordering = '-market_cap_usd';
  bool gainersOnly = false;
  Timer? _debounce;

  // Pagination state.
  int page = 1;
  int totalPages = 1;
  bool loadingMore = false;
  String pageError = '';
  static const int pageSize = 20;

  bool get hasNext => page < totalPages;

  List<Coin> _parse(List raw, {bool gains = false}) {
    var list = [for (final row in raw) Coin.tryFromJson(row)].whereType<Coin>().toList();
    if (gainersOnly || gains) list = list.where((c) => (c.change24h ?? 0) > 0).toList();
    return list;
  }

  String get _cacheKey => 'coins:$search:$ordering:$gainersOnly';

  /// Pull-to-refresh: best-effort live refresh first (throttled server-side,
  /// failures ignored), then load page 1 (live or cached).
  Future<void> refresh({bool live = true}) async {
    state = LoadState.loading;
    error = '';
    pageError = '';
    notifyListeners();
    if (live) {
      try {
        await api.refreshCoins();
      } catch (_) {
        // Ignore: the list load below will fall back to cache.
      }
    }
    try {
      final res = await api.coins(search: search, ordering: ordering, page: 1, pageSize: pageSize);
      coins = _parse(res.items);
      page = res.page;
      totalPages = res.totalPages;
      offline = false;
      await cache.save(_cacheKey, res.items);
      savedAt = DateTime.now();
      state = coins.isEmpty ? LoadState.empty : LoadState.loaded;
    } on ApiException catch (e) {
      error = e.message;
      final hit = await cache.load(_cacheKey);
      if (hit.data != null) {
        coins = _parse(hit.data as List);
        savedAt = hit.savedAt;
        offline = true;
        page = 1;
        totalPages = 1;
        state = coins.isEmpty ? LoadState.empty : LoadState.loaded;
      } else {
        state = LoadState.error;
      }
    }
    notifyListeners();
  }

  /// Infinite scroll: append the next page. No-op when nothing left or busy.
  Future<void> loadMore() async {
    if (state != LoadState.loaded || loadingMore || !hasNext || offline) return;
    loadingMore = true;
    pageError = '';
    notifyListeners();
    try {
      final res = await api.coins(
          search: search, ordering: ordering, page: page + 1, pageSize: pageSize);
      coins = [...coins, ..._parse(res.items)];
      page = res.page;
      totalPages = res.totalPages;
      await cache.save(_cacheKey, [for (final c in coins) c.toJson()]);
      savedAt = DateTime.now();
    } on ApiException catch (e) {
      pageError = e.message;
    }
    loadingMore = false;
    notifyListeners();
  }

  void onSearch(String v) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      search = v;
      refresh();
    });
  }

  void setOrdering(String o) {
    ordering = o;
    refresh();
  }

  void setGainers(bool v) {
    gainersOnly = v;
    refresh();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }
}
