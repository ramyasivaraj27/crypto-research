import 'package:crypto_research/models/market.dart';
import 'package:crypto_research/utils/format.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Coin parses market fields', () {
    final coin = Coin.fromJson({
      'id': 1,
      'symbol': 'BTC',
      'name': 'Bitcoin',
      'image_url': '',
      'current_price_usd': '67000.12345678',
      'price_change_24h_pct': '2.5',
      'volume_24h_usd': '35000000000',
      'market_cap_usd': '1320000000000',
      'circulating_supply': '19700000',
      'total_supply': '21000000',
      'is_stale': false,
    });
    expect(coin.symbol, 'BTC');
    expect(coin.price, 67000.12345678);
    expect(fmtPrice(coin.price), contains('67,000'));
    expect(fmtPct(coin.change24h), '+2.50%');
  });

  test('Coin handles null market data', () {
    final coin = Coin.fromJson({'id': 2, 'symbol': 'NEW', 'name': 'New Coin'});
    expect(coin.price, isNull);
    expect(fmtPrice(coin.price), '—');
  });

  test('PricePoint parses chart data', () {
    final p = PricePoint.fromJson({'t': 1700000000000, 'price': '67000.5'});
    expect(p.price, 67000.5);
    expect(p.t.millisecondsSinceEpoch, 1700000000000);
  });

  test('Coin.tryFromJson skips malformed rows instead of throwing', () {
    expect(Coin.tryFromJson({'symbol': 'NOID', 'name': 'No Id'}), isNull);
    expect(Coin.tryFromJson('garbage'), isNull);
    expect(Coin.tryFromJson({'id': 1, 'symbol': 'BTC', 'name': 'Bitcoin'}), isNotNull);
  });

  test('MarketOverview rejects empty payloads (never silent dashes)', () {
    expect(
      () => MarketOverview.fromJson({'market': {'total_market_cap_usd': null}, 'top_coins': []}),
      throwsFormatException,
    );
    final ok = MarketOverview.fromJson({
      'market': {'total_market_cap_usd': '100', 'total_volume_24h_usd': '10', 'btc_dominance_pct': '50', 'is_stale': false},
      'top_coins': [
        {'id': 1, 'symbol': 'BTC', 'name': 'Bitcoin'},
        {'nope': true},
      ],
    });
    expect(ok.top.length, 1); // bad row skipped, good row kept
    expect(ok.isEmpty, isFalse);
  });
}
