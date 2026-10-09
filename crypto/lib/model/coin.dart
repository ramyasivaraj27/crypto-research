import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

import 'serializers.dart';

part 'coin.g.dart';

abstract class Coin implements Built<Coin, CoinBuilder> {
  int get id;
  String get symbol;
  String get name;
  @BuiltValueField(wireName: 'image_url')
  String get imageUrl;
  @BuiltValueField(wireName: 'current_price_usd')
  double? get price;
  @BuiltValueField(wireName: 'price_change_24h_pct')
  double? get change24h;
  @BuiltValueField(wireName: 'volume_24h_usd')
  double? get volume24h;
  @BuiltValueField(wireName: 'market_cap_usd')
  double? get marketCap;
  @BuiltValueField(wireName: 'circulating_supply')
  double? get circulating;
  @BuiltValueField(wireName: 'total_supply')
  double? get total;
  @BuiltValueField(wireName: 'is_stale')
  bool get isStale;

  Coin._();
  factory Coin([void Function(CoinBuilder)? updates]) = _$Coin;

  static Serializer<Coin> get serializer => _$coinSerializer;

  static void _initializeBuilder(CoinBuilder b) {
    b
      ..imageUrl = ''
      ..isStale = false;
  }

  Map<String, dynamic>? toJson() =>
      serializers.serializeWith(Coin.serializer, this) as Map<String, dynamic>?;

  /// Strict parse: throws on shape mismatch so callers show error+retry.
  static Coin? fromJson(Map<String, dynamic> json) =>
      serializers.deserializeWith(Coin.serializer, json);

  /// Lenient row: null instead of throwing (one bad row must not blank a list).
  static Coin? tryFromJson(dynamic j) {
    if (j is! Map) return null;
    try {
      return Coin.fromJson(j.cast<String, dynamic>());
      // ignore: avoid_catches_without_on_clauses
    } catch (_) {
      return null;
    }
  }
}
