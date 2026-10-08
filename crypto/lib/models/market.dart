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

  static int? _id(dynamic v) {
    if (v is num) return v.toInt();
    return int.tryParse(v?.toString() ?? '');
  }

  /// Strict parse: throws [FormatException] on shape mismatch so callers
  /// show error+retry instead of silent dashes.
  factory Coin.fromJson(Map<String, dynamic> j) {
    final id = _id(j['id']);
    if (id == null) throw const FormatException('Coin is missing id');
    if (j['symbol'] == null || j['name'] == null) {
      throw const FormatException('Coin is missing symbol/name');
    }
    return Coin(
      id: id,
      symbol: j['symbol'].toString(),
      name: j['name'].toString(),
      imageUrl: (j['image_url'] ?? '').toString(),
      price: _d(j['current_price_usd']),
      change24h: _d(j['price_change_24h_pct']),
      volume24h: _d(j['volume_24h_usd']),
      marketCap: _d(j['market_cap_usd']),
      circulating: _d(j['circulating_supply']),
      total: _d(j['total_supply']),
      isStale: j['is_stale'] == true,
    );
  }

  /// Lenient row: returns null instead of throwing (one bad row must not
  /// blank the whole list).
  static Coin? tryFromJson(dynamic j) {
    if (j is! Map) return null;
    try {
      return Coin.fromJson(j.cast<String, dynamic>());
    } on FormatException {
      return null;
    }
  }

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

  factory PricePoint.fromJson(Map<String, dynamic> j) {
    final t = j['t'];
    if (t is! num) throw const FormatException('Price point is missing t');
    return PricePoint(
      DateTime.fromMillisecondsSinceEpoch(t.toInt()),
      double.tryParse(j['price'].toString()) ?? 0,
    );
  }

  static PricePoint? tryFromJson(dynamic j) {
    if (j is! Map) return null;
    try {
      return PricePoint.fromJson(j.cast<String, dynamic>());
    } on FormatException {
      return null;
    }
  }
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
    final m = j['market'];
    if (m is! Map) throw const FormatException('Market response has no market object');
    final mc = m.cast<String, dynamic>();
    final topRaw = j['top_coins'];
    if (topRaw != null && topRaw is! List) {
      throw const FormatException('Market response has malformed top_coins');
    }
    final top = <Coin>[];
    for (final row in (topRaw as List? ?? [])) {
      final coin = Coin.tryFromJson(row);
      if (coin != null) top.add(coin);
    }
    final overview = MarketOverview(
      totalMcap: _d(mc['total_market_cap_usd']),
      totalVolume: _d(mc['total_volume_24h_usd']),
      btcDom: _d(mc['btc_dominance_pct']),
      isStale: mc['is_stale'] == true,
      top: top,
    );
    if (overview.isEmpty) throw const FormatException('Market response contains no usable data');
    return overview;
  }

  /// True when the payload parsed but carries nothing displayable —
  /// callers must treat this as an error (retry), never as dashes.
  bool get isEmpty => totalMcap == null && totalVolume == null && btcDom == null && top.isEmpty;
}
