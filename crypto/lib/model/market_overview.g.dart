// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'market_overview.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

Serializer<MarketOverview> _$marketOverviewSerializer =
    _$MarketOverviewSerializer();

class _$MarketOverviewSerializer
    implements StructuredSerializer<MarketOverview> {
  @override
  final Iterable<Type> types = const [MarketOverview, _$MarketOverview];
  @override
  final String wireName = 'MarketOverview';

  @override
  Iterable<Object?> serialize(
    Serializers serializers,
    MarketOverview object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = <Object?>[
      'is_stale',
      serializers.serialize(
        object.isStale,
        specifiedType: const FullType(bool),
      ),
      'top_coins',
      serializers.serialize(
        object.top,
        specifiedType: const FullType(BuiltList, const [const FullType(Coin)]),
      ),
    ];
    Object? value;
    value = object.totalMcap;
    if (value != null) {
      result
        ..add('total_market_cap_usd')
        ..add(
          serializers.serialize(value, specifiedType: const FullType(double)),
        );
    }
    value = object.totalVolume;
    if (value != null) {
      result
        ..add('total_volume_24h_usd')
        ..add(
          serializers.serialize(value, specifiedType: const FullType(double)),
        );
    }
    value = object.btcDom;
    if (value != null) {
      result
        ..add('btc_dominance_pct')
        ..add(
          serializers.serialize(value, specifiedType: const FullType(double)),
        );
    }
    return result;
  }

  @override
  MarketOverview deserialize(
    Serializers serializers,
    Iterable<Object?> serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = MarketOverviewBuilder();

    final iterator = serialized.iterator;
    while (iterator.moveNext()) {
      final key = iterator.current! as String;
      iterator.moveNext();
      final Object? value = iterator.current;
      switch (key) {
        case 'total_market_cap_usd':
          result.totalMcap =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(double),
                  )
                  as double?;
          break;
        case 'total_volume_24h_usd':
          result.totalVolume =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(double),
                  )
                  as double?;
          break;
        case 'btc_dominance_pct':
          result.btcDom =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(double),
                  )
                  as double?;
          break;
        case 'is_stale':
          result.isStale =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(bool),
                  )!
                  as bool;
          break;
        case 'top_coins':
          result.top.replace(
            serializers.deserialize(
                  value,
                  specifiedType: const FullType(BuiltList, const [
                    const FullType(Coin),
                  ]),
                )!
                as BuiltList<Object?>,
          );
          break;
      }
    }

    return result.build();
  }
}

class _$MarketOverview extends MarketOverview {
  @override
  final double? totalMcap;
  @override
  final double? totalVolume;
  @override
  final double? btcDom;
  @override
  final bool isStale;
  @override
  final BuiltList<Coin> top;

  factory _$MarketOverview([void Function(MarketOverviewBuilder)? updates]) =>
      (MarketOverviewBuilder()..update(updates))._build();

  _$MarketOverview._({
    this.totalMcap,
    this.totalVolume,
    this.btcDom,
    required this.isStale,
    required this.top,
  }) : super._();
  @override
  MarketOverview rebuild(void Function(MarketOverviewBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  MarketOverviewBuilder toBuilder() => MarketOverviewBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is MarketOverview &&
        totalMcap == other.totalMcap &&
        totalVolume == other.totalVolume &&
        btcDom == other.btcDom &&
        isStale == other.isStale &&
        top == other.top;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, totalMcap.hashCode);
    _$hash = $jc(_$hash, totalVolume.hashCode);
    _$hash = $jc(_$hash, btcDom.hashCode);
    _$hash = $jc(_$hash, isStale.hashCode);
    _$hash = $jc(_$hash, top.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'MarketOverview')
          ..add('totalMcap', totalMcap)
          ..add('totalVolume', totalVolume)
          ..add('btcDom', btcDom)
          ..add('isStale', isStale)
          ..add('top', top))
        .toString();
  }
}

class MarketOverviewBuilder
    implements Builder<MarketOverview, MarketOverviewBuilder> {
  _$MarketOverview? _$v;

  double? _totalMcap;
  double? get totalMcap => _$this._totalMcap;
  set totalMcap(double? totalMcap) => _$this._totalMcap = totalMcap;

  double? _totalVolume;
  double? get totalVolume => _$this._totalVolume;
  set totalVolume(double? totalVolume) => _$this._totalVolume = totalVolume;

  double? _btcDom;
  double? get btcDom => _$this._btcDom;
  set btcDom(double? btcDom) => _$this._btcDom = btcDom;

  bool? _isStale;
  bool? get isStale => _$this._isStale;
  set isStale(bool? isStale) => _$this._isStale = isStale;

  ListBuilder<Coin>? _top;
  ListBuilder<Coin> get top => _$this._top ??= ListBuilder<Coin>();
  set top(ListBuilder<Coin>? top) => _$this._top = top;

  MarketOverviewBuilder() {
    MarketOverview._initializeBuilder(this);
  }

  MarketOverviewBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _totalMcap = $v.totalMcap;
      _totalVolume = $v.totalVolume;
      _btcDom = $v.btcDom;
      _isStale = $v.isStale;
      _top = $v.top.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(MarketOverview other) {
    _$v = other as _$MarketOverview;
  }

  @override
  void update(void Function(MarketOverviewBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  MarketOverview build() => _build();

  _$MarketOverview _build() {
    _$MarketOverview _$result;
    try {
      _$result =
          _$v ??
          _$MarketOverview._(
            totalMcap: totalMcap,
            totalVolume: totalVolume,
            btcDom: btcDom,
            isStale: BuiltValueNullFieldError.checkNotNull(
              isStale,
              r'MarketOverview',
              'isStale',
            ),
            top: top.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'top';
        top.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
          r'MarketOverview',
          _$failedField,
          e.toString(),
        );
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
