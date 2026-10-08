class Coin {
  final int id;
  final String symbol;
  final String name;
  final String imageUrl;
  final double? price;
  final double? change24h;
  final double? volume24h;
  final double? marketCap;
  final double? circulating;
  final double? total;
  final bool isStale;

  Coin({
    required this.id,
    required this.symbol,
    required this.name,
    this.imageUrl = '',
    this.price,
    this.change24h,
    this.volume24h,
    this.marketCap,
    this.circulating,
    this.total,
    this.isStale = false,
  });

  static double? _d(dynamic v) => v == null ? null : double.tryParse(v.toString());

  factory Coin.fromJson(Map<String, dynamic> j) => Coin(
        id: (j['id'] as num).toInt(),
        symbol: (j['symbol'] ?? '').toString(),
        name: (j['name'] ?? '').toString(),
        imageUrl: (j['image_url'] ?? '').toString(),
        price: _d(j['current_price_usd']),
        change24h: _d(j['price_change_24h_pct']),
        volume24h: _d(j['volume_24h_usd']),
        marketCap: _d(j['market_cap_usd']),
        circulating: _d(j['circulating_supply']),
        total: _d(j['total_supply']),
        isStale: j['is_stale'] == true,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'symbol': symbol,
        'name': name,
        'image_url': imageUrl,
        'current_price_usd': price?.toString(),
        'price_change_24h_pct': change24h?.toString(),
        'volume_24h_usd': volume24h?.toString(),
        'market_cap_usd': marketCap?.toString(),
        'circulating_supply': circulating?.toString(),
        'total_supply': total?.toString(),
        'is_stale': isStale,
      };
}

class PricePoint {
  final DateTime t;
  final double price;
  PricePoint(this.t, this.price);

  factory PricePoint.fromJson(Map<String, dynamic> j) => PricePoint(
        DateTime.fromMillisecondsSinceEpoch((j['t'] as num).toInt()),
        double.tryParse(j['price'].toString()) ?? 0,
      );
}

class MarketOverview {
  final double? totalMcap;
  final double? totalVolume;
  final double? btcDom;
  final bool isStale;
  final List<Coin> top;
  MarketOverview({this.totalMcap, this.totalVolume, this.btcDom, this.isStale = false, this.top = const []});

  static double? _d(dynamic v) => v == null ? null : double.tryParse(v.toString());

  factory MarketOverview.fromJson(Map<String, dynamic> j) {
    final m = (j['market'] as Map).cast<String, dynamic>();
    return MarketOverview(
      totalMcap: _d(m['total_market_cap_usd']),
      totalVolume: _d(m['total_volume_24h_usd']),
      btcDom: _d(m['btc_dominance_pct']),
      isStale: m['is_stale'] == true,
      top: ((j['top_coins'] as List? ?? []).cast<Map<String, dynamic>>().map(Coin.fromJson).toList()),
    );
  }
}
