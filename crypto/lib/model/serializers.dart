import 'package:built_collection/built_collection.dart';
import 'package:built_value/serializer.dart';
import 'package:built_value/standard_json_plugin.dart';

import 'coin.dart';
import 'datetime.dart';
import 'market_overview.dart';
import 'price_point.dart';

part 'serializers.g.dart';

@SerializersFor([
  Coin,
  PricePoint,
  MarketOverview,
])
Serializers serializers = (_$serializers.toBuilder()
      ..add(MillisDateTimeSerializer())
      ..add(FlexDoubleSerializer())
      ..addPlugin(StandardJsonPlugin())
      ..addBuilderFactory(const FullType(BuiltList, [FullType(Coin)]), () => ListBuilder<Coin>())
    ).build();
