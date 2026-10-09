import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';

import 'coin.dart';
import 'load_state.dart';

part 'market_state.g.dart';

/// Immutable state for the coin list / search (mirrors balm's PostState).
abstract class MarketState implements Built<MarketState, MarketStateBuilder> {
  LoadState get status;
  BuiltList<Coin> get coins;
  String get error;
  DateTime? get savedAt;
  bool get offline;
  String get search;
  String get ordering;
  bool get gainersOnly;
  int get page;
  int get totalPages;
  bool get loadingMore;
  String get pageError;

  bool get hasNext => page < totalPages;

  MarketState._();
  factory MarketState([void Function(MarketStateBuilder)? updates]) = _$MarketState;

  static void _initializeBuilder(MarketStateBuilder b) {
    b
      ..status = LoadState.idle
      ..coins = ListBuilder<Coin>()
      ..error = ''
      ..offline = false
      ..search = ''
      ..ordering = '-market_cap_usd'
      ..gainersOnly = false
      ..page = 1
      ..totalPages = 1
      ..loadingMore = false
      ..pageError = '';
  }
}
