import 'package:crypto_research/core/api_client.dart';
import 'package:crypto_research/core/cache_store.dart';
import 'package:crypto_research/view_model/market_view_model.dart';
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
      {String search = '',
      String ordering = '-market_cap_usd',
      int page = 1,
      int pageSize = 20}) async {
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
    final vm = MarketViewModel(
      FakeApi([
        [coinJson(1, 'BTC'), coinJson(2, 'ETH')],
        [coinJson(3, 'SOL')],
      ]),
      CacheStore(),
    );
    await vm.refresh(live: false);
    expect(vm.state.coins.map((c) => c.symbol), ['BTC', 'ETH']);
    expect(vm.state.hasNext, isTrue);

    await vm.loadMore();
    expect(vm.state.coins.map((c) => c.symbol), ['BTC', 'ETH', 'SOL']);
    expect(vm.state.hasNext, isFalse);
    expect(vm.state.loadingMore, isFalse);
  });

  test('loadMore is a no-op at the last page', () async {
    final api = FakeApi([
      [coinJson(1, 'BTC')],
    ]);
    final vm = MarketViewModel(api, CacheStore());
    await vm.refresh(live: false);
    final callsAfterRefresh = api.calls;
    await vm.loadMore();
    expect(api.calls, callsAfterRefresh); // no extra network call
  });

  test('search resets to page 1', () async {
    final vm = MarketViewModel(
      FakeApi([
        [coinJson(1, 'BTC')],
      ]),
      CacheStore(),
    );
    vm.state = vm.state.rebuild((b) => b..page = 5); // simulate deep scroll
    await vm.refresh(live: false);
    expect(vm.state.page, 1);
  });
}
