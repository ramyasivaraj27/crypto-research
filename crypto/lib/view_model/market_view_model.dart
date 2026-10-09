import 'dart:async';

import '../core/api_client.dart';
import '../core/cache_store.dart';
import '../core/view_model/view_model.dart';
import '../model/coin.dart';
import '../model/load_state.dart';
import '../model/market_state.dart';
import '../provider/app_state_notifier.dart';

/// Coin list with search/filter/sort + offline cache fallback.
class MarketViewModel extends AppStateNotifier<MarketState> implements AppBaseViewModel {
  final ApiClient api;
  final CacheStore cache;
  MarketViewModel(this.api, this.cache) : super(MarketState());

  static const int pageSize = 20;

  Timer? _debounce;

  @override
  Future<void> init() => refresh(live: false);

  List<Coin> _parse(List raw) {
    var list = [for (final row in raw) Coin.tryFromJson(row)].whereType<Coin>().toList();
    if (state.gainersOnly) {
      list = list.where((c) => (c.change24h ?? 0) > 0).toList();
    }
    return list;
  }

  String get _cacheKey => 'coins:${state.search}:${state.ordering}:${state.gainersOnly}';

  /// Pull-to-refresh: best-effort live refresh first (throttled server-side,
  /// failures ignored), then load page 1 (live or cached).
  Future<void> refresh({bool live = true}) async {
    state = state.rebuild((b) => b
      ..status = LoadState.loading
      ..error = ''
      ..pageError = '');
    if (live) {
      try {
        await api.refreshCoins();
      } catch (_) {
        // Ignore: the list load below will fall back to cache.
      }
    }
    try {
      final res = await api.coins(
          search: state.search, ordering: state.ordering, page: 1, pageSize: pageSize);
      final coins = _parse(res.items);
      state = state.rebuild((b) => b
        ..status = coins.isEmpty ? LoadState.empty : LoadState.loaded
        ..coins.replace(coins)
        ..page = res.page
        ..totalPages = res.totalPages
        ..offline = false
        ..savedAt = DateTime.now());
      await cache.save(_cacheKey, res.items);
    } on ApiException catch (e) {
      final hit = await cache.load(_cacheKey);
      if (hit.data != null) {
        final coins = _parse(hit.data as List);
        state = state.rebuild((b) => b
          ..status = coins.isEmpty ? LoadState.empty : LoadState.loaded
          ..coins.replace(coins)
          ..savedAt = hit.savedAt
          ..offline = true
          ..page = 1
          ..totalPages = 1
          ..error = e.message);
      } else {
        state = state.rebuild((b) => b
          ..status = LoadState.error
          ..error = e.message);
      }
    }
  }

  /// Infinite scroll: append the next page. No-op when nothing left or busy.
  Future<void> loadMore() async {
    if (state.status != LoadState.loaded || state.loadingMore || !state.hasNext || state.offline) {
      return;
    }
    state = state.rebuild((b) => b
      ..loadingMore = true
      ..pageError = '');
    try {
      final res = await api.coins(
          search: state.search, ordering: state.ordering, page: state.page + 1, pageSize: pageSize);
      final coins = [...state.coins, ..._parse(res.items)];
      state = state.rebuild((b) => b
        ..coins.replace(coins)
        ..page = res.page
        ..totalPages = res.totalPages
        ..savedAt = DateTime.now()
        ..loadingMore = false);
      await cache.save(_cacheKey, [for (final c in coins) c.toJson()]);
    } on ApiException catch (e) {
      state = state.rebuild((b) => b
        ..loadingMore = false
        ..pageError = e.message);
    }
  }

  void onSearch(String v) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      state = state.rebuild((b) => b..search = v);
      refresh();
    });
  }

  void setOrdering(String o) {
    state = state.rebuild((b) => b..ordering = o);
    refresh();
  }

  void setGainers(bool v) {
    state = state.rebuild((b) => b..gainersOnly = v);
    refresh();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }
}
