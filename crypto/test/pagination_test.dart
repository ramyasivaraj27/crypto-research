import 'package:crypto_research/core/api_client.dart';
import 'package:crypto_research/core/cache_store.dart';
import 'package:crypto_research/providers/market_provider.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

Map<String, dynamic> coinJson(int id, String symbol) => {
      'id': id,
      'symbol': symbol,
      'name': 'Coin $symbol',
      'current_price_usd': '1.0',
    };

class FakeApi extends ApiClient {
  final List<List<Map<String, dynamic>>> pages;
  int calls = 0;
  FakeApi(this.pages);

  @override
  Future<PagedResult> coins(
      {String search = '', String ordering = '-market_cap_usd', int page = 1, int pageSize = 20}) async {
    calls++;
    final items = pages[page - 1];
    return PagedResult(items: items, page: page, totalPages: pages.length);
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('PagedResult.hasNext reflects page vs totalPages', () {
    expect(const PagedResult(items: [], page: 1, totalPages: 3).hasNext, isTrue);
    expect(const PagedResult(items: [], page: 3, totalPages: 3).hasNext, isFalse);
  });

  test('refresh loads page 1, loadMore appends page 2', () async {
    final provider = MarketProvider(
      FakeApi([
        [coinJson(1, 'BTC'), coinJson(2, 'ETH')],
        [coinJson(3, 'SOL')],
      ]),
      CacheStore(),
    );
    await provider.refresh(live: false);
    expect(provider.coins.map((c) => c.symbol), ['BTC', 'ETH']);
    expect(provider.hasNext, isTrue);

    await provider.loadMore();
    expect(provider.coins.map((c) => c.symbol), ['BTC', 'ETH', 'SOL']);
    expect(provider.hasNext, isFalse);
    expect(provider.loadingMore, isFalse);
  });

  test('loadMore is a no-op at the last page', () async {
    final api = FakeApi([
      [coinJson(1, 'BTC')],
    ]);
    final provider = MarketProvider(api, CacheStore());
    await provider.refresh(live: false);
    final callsAfterRefresh = api.calls;
    await provider.loadMore();
    expect(api.calls, callsAfterRefresh); // no extra network call
  });

  test('search resets to page 1', () async {
    final provider = MarketProvider(
      FakeApi([
        [coinJson(1, 'BTC')],
      ]),
      CacheStore(),
    );
    provider.page = 5; // simulate deep scroll
    provider.search = 'btc';
    await provider.refresh(live: false);
    expect(provider.page, 1);
  });
}
