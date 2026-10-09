import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';

import 'coin.dart';

part 'watchlist_state.g.dart';

abstract class WatchlistState implements Built<WatchlistState, WatchlistStateBuilder> {
  bool get loading;
  String get error;
  BuiltList<Coin> get items;
  DateTime? get savedAt;
  bool get offline;
  int get page;
  int get totalPages;
  bool get loadingMore;
  String get pageError;

  bool get hasNext => page < totalPages;
  BuiltSet<int> get starredIds => BuiltSet<int>(items.map((c) => c.id));

  WatchlistState._();
  factory WatchlistState([void Function(WatchlistStateBuilder)? updates]) = _$WatchlistState;

  static void _initializeBuilder(WatchlistStateBuilder b) {
    b
      ..loading = false
      ..error = ''
      ..items = ListBuilder<Coin>()
      ..offline = false
      ..page = 1
      ..totalPages = 1
      ..loadingMore = false
      ..pageError = '';
  }
}
