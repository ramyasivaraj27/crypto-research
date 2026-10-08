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

  Future<void> refresh() async {
    state = LoadState.loading;
    error = '';
    notifyListeners();
    try {
      final raw = await api.coins(search: search, ordering: ordering);
      var list = raw.cast<Map<String, dynamic>>().map(Coin.fromJson).toList();
      if (gainersOnly) list = list.where((c) => (c.change24h ?? 0) > 0).toList();
      coins = list;
      offline = false;
      await cache.save('coins:$search:$ordering:$gainersOnly', raw);
      savedAt = DateTime.now();
      state = coins.isEmpty ? LoadState.empty : LoadState.loaded;
    } on ApiException catch (e) {
      error = e.message;
      final hit = await cache.load('coins:$search:$ordering:$gainersOnly');
      if (hit.data != null) {
        final raw = (hit.data as List).cast<Map<String, dynamic>>();
        var list = raw.map(Coin.fromJson).toList();
        if (gainersOnly) list = list.where((c) => (c.change24h ?? 0) > 0).toList();
        coins = list;
        savedAt = hit.savedAt;
        offline = true;
        state = coins.isEmpty ? LoadState.empty : LoadState.loaded;
      } else {
        state = LoadState.error;
      }
    }
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
