import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

import 'serializers.dart';

part 'price_point.g.dart';

abstract class PricePoint implements Built<PricePoint, PricePointBuilder> {
  @BuiltValueField(wireName: 't')
  DateTime get t;
  double get price;

  PricePoint._();
  factory PricePoint([void Function(PricePointBuilder)? updates]) = _$PricePoint;

  static Serializer<PricePoint> get serializer => _$pricePointSerializer;

  static PricePoint? fromJson(Map<String, dynamic> json) =>
      serializers.deserializeWith(PricePoint.serializer, json);

  static PricePoint? tryFromJson(dynamic j) {
    if (j is! Map) return null;
    try {
      return PricePoint.fromJson(j.cast<String, dynamic>());
      // ignore: avoid_catches_without_on_clauses
    } catch (_) {
      return null;
    }
  }
}
