import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

import 'coin.dart';

part 'market_overview.g.dart';

abstract class MarketOverview implements Built<MarketOverview, MarketOverviewBuilder> {
  @BuiltValueField(wireName: 'total_market_cap_usd')
  double? get totalMcap;
  @BuiltValueField(wireName: 'total_volume_24h_usd')
  double? get totalVolume;
  @BuiltValueField(wireName: 'btc_dominance_pct')
  double? get btcDom;
  @BuiltValueField(wireName: 'is_stale')
  bool get isStale;
  @BuiltValueField(wireName: 'top_coins')
  BuiltList<Coin> get top;

  MarketOverview._();
  factory MarketOverview([void Function(MarketOverviewBuilder)? updates]) = _$MarketOverview;

  static Serializer<MarketOverview> get serializer => _$marketOverviewSerializer;

  static void _initializeBuilder(MarketOverviewBuilder b) {
    b
      ..isStale = false
      ..top = ListBuilder<Coin>();
  }

  /// Strict parse that tolerates bad rows but rejects empty payloads, so
  /// callers show error+retry instead of silent dashes.
  static MarketOverview fromJson(Map<String, dynamic> json) {
    final m = json['market'];
    if (m is! Map) throw const FormatException('Market response has no market object');
    final mc = m.cast<String, dynamic>();
    final topRaw = json['top_coins'];
    if (topRaw != null && topRaw is! List) {
      throw const FormatException('Market response has malformed top_coins');
    }
    final top = <Coin>[];
    for (final row in (topRaw as List? ?? [])) {
      final coin = Coin.tryFromJson(row);
      if (coin != null) top.add(coin);
    }
    final overview = MarketOverview((b) => b
      ..totalMcap = _d(mc['total_market_cap_usd'])
      ..totalVolume = _d(mc['total_volume_24h_usd'])
      ..btcDom = _d(mc['btc_dominance_pct'])
      ..isStale = mc['is_stale'] == true
      ..top.replace(top));
    if (overview.isEmpty) throw const FormatException('Market response contains no usable data');
    return overview;
  }

  static double? _d(dynamic v) => v == null ? null : double.tryParse(v.toString());

  /// True when the payload parsed but carries nothing displayable.
  bool get isEmpty => totalMcap == null && totalVolume == null && btcDom == null && top.isEmpty;
}
