import 'package:built_value/serializer.dart';

/// DateTime as millis-since-epoch int (CoinGecko `market_chart` shape).
class MillisDateTimeSerializer implements PrimitiveSerializer<DateTime> {
  @override
  DateTime deserialize(Serializers serializers, Object? serialized,
      {FullType specifiedType = FullType.unspecified}) {
    if (serialized is num) {
      return DateTime.fromMillisecondsSinceEpoch(serialized.toInt());
    }
    throw FormatException('Expected millis int for DateTime, got $serialized');
  }

  @override
  Object serialize(Serializers serializers, DateTime date,
      {FullType specifiedType = FullType.unspecified}) {
    return date.millisecondsSinceEpoch;
  }

  @override
  Iterable<Type> get types => [DateTime];

  @override
  String get wireName => 'DateTime';
}

/// `double` that also accepts JSON strings (DRF renders Decimals as strings).
class FlexDoubleSerializer implements PrimitiveSerializer<double> {
  @override
  double deserialize(Serializers serializers, Object? serialized,
      {FullType specifiedType = FullType.unspecified}) {
    if (serialized is num) return serialized.toDouble();
    if (serialized is String) {
      final v = double.tryParse(serialized);
      if (v != null) return v;
    }
    throw FormatException('Expected num-or-string double, got $serialized');
  }

  @override
  Object serialize(Serializers serializers, double value,
      {FullType specifiedType = FullType.unspecified}) {
    return value;
  }

  @override
  Iterable<Type> get types => [double];

  @override
  String get wireName => 'double';
}
