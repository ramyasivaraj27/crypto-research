import '../core/api_client.dart';
import '../core/cache_store.dart';
import '../core/view_model/view_model.dart';
import '../model/coin.dart';
import '../model/watchlist_state.dart';
import '../provider/app_state_notifier.dart';
import 'auth_view_model.dart';

/// Watchlist mirrored on-device; works offline after first load.
class WatchlistViewModel extends AppStateNotifier<WatchlistState> implements AppBaseViewModel {
  final ApiClient api;
  final AuthViewModel auth;
  final CacheStore cache;
  WatchlistViewModel(this.api, this.auth, this.cache) : super(WatchlistState());

  static const int pageSize = 20;

  @override
  Future<void> init() => refresh();

  List<Coin> parseItems(List raw) => [
        for (final e in raw)
          if (e is Map) Coin.tryFromJson(e['coin'])
      ].whereType<Coin>().toList();

  Future<void> refresh() async {
    if (!auth.isLoggedIn) return;
    state = state.rebuild((b) => b
      ..loading = true
      ..error = ''
      ..pageError = '');
    try {
      final res = await api.watchlistItems(page: 1, pageSize: pageSize);
      state = state.rebuild((b) => b
        ..items.replace(parseItems(res.items))
        ..page = res.page
        ..totalPages = res.totalPages
        ..offline = false
        ..savedAt = DateTime.now()
        ..loading = false);
      await cache.save('watchlist', res.items);
    } on ApiException catch (e) {
      final hit = await cache.load('watchlist');
      if (hit.data != null) {
        state = state.rebuild((b) => b
          ..items.replace(parseItems(hit.data as List))
          ..savedAt = hit.savedAt
          ..offline = true
          ..page = 1
          ..totalPages = 1
          ..loading = false
          ..error = e.message);
      } else {
        state = state.rebuild((b) => b
          ..loading = false
          ..error = e.message);
      }
    }
  }

  Future<void> loadMore() async {
    if (state.loading || state.loadingMore || !state.hasNext || state.offline || !auth.isLoggedIn) {
      return;
    }
    state = state.rebuild((b) => b
      ..loadingMore = true
      ..pageError = '');
    try {
      final res = await api.watchlistItems(page: state.page + 1, pageSize: pageSize);
      final items = [...state.items, ...parseItems(res.items)];
      state = state.rebuild((b) => b
        ..items.replace(items)
        ..page = res.page
        ..totalPages = res.totalPages
        ..savedAt = DateTime.now()
        ..loadingMore = false);
      await cache.save('watchlist', [for (final c in items) {'coin': c.toJson()}]);
    } on ApiException catch (e) {
      state = state.rebuild((b) => b
        ..loadingMore = false
        ..pageError = e.message);
    }
  }

  Future<void> toggle(int coinId) async {
    try {
      final res = await api.toggleStar(coinId);
      await refresh();
      if (res['starred'] == false) {
        state = state.rebuild((b) => b..items.removeWhere((c) => c.id == coinId));
      }
    } on ApiException catch (e) {
      state = state.rebuild((b) => b..error = e.message);
    }
  }
}
