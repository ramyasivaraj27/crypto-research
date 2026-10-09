// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'coin.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

Serializer<Coin> _$coinSerializer = _$CoinSerializer();

class _$CoinSerializer implements StructuredSerializer<Coin> {
  @override
  final Iterable<Type> types = const [Coin, _$Coin];
  @override
  final String wireName = 'Coin';

  @override
  Iterable<Object?> serialize(
    Serializers serializers,
    Coin object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = <Object?>[
      'id',
      serializers.serialize(object.id, specifiedType: const FullType(int)),
      'symbol',
      serializers.serialize(
        object.symbol,
        specifiedType: const FullType(String),
      ),
      'name',
      serializers.serialize(object.name, specifiedType: const FullType(String)),
      'image_url',
      serializers.serialize(
        object.imageUrl,
        specifiedType: const FullType(String),
      ),
      'is_stale',
      serializers.serialize(
        object.isStale,
        specifiedType: const FullType(bool),
      ),
    ];
    Object? value;
    value = object.price;
    if (value != null) {
      result
        ..add('current_price_usd')
        ..add(
          serializers.serialize(value, specifiedType: const FullType(double)),
        );
    }
    value = object.change24h;
    if (value != null) {
      result
        ..add('price_change_24h_pct')
        ..add(
          serializers.serialize(value, specifiedType: const FullType(double)),
        );
    }
    value = object.volume24h;
    if (value != null) {
      result
        ..add('volume_24h_usd')
        ..add(
          serializers.serialize(value, specifiedType: const FullType(double)),
        );
    }
    value = object.marketCap;
    if (value != null) {
      result
        ..add('market_cap_usd')
        ..add(
          serializers.serialize(value, specifiedType: const FullType(double)),
        );
    }
    value = object.circulating;
    if (value != null) {
      result
        ..add('circulating_supply')
        ..add(
          serializers.serialize(value, specifiedType: const FullType(double)),
        );
    }
    value = object.total;
    if (value != null) {
      result
        ..add('total_supply')
        ..add(
          serializers.serialize(value, specifiedType: const FullType(double)),
        );
    }
    return result;
  }

  @override
  Coin deserialize(
    Serializers serializers,
    Iterable<Object?> serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = CoinBuilder();

    final iterator = serialized.iterator;
    while (iterator.moveNext()) {
      final key = iterator.current! as String;
      iterator.moveNext();
      final Object? value = iterator.current;
      switch (key) {
        case 'id':
          result.id =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(int),
                  )!
                  as int;
          break;
        case 'symbol':
          result.symbol =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(String),
                  )!
                  as String;
          break;
        case 'name':
          result.name =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(String),
                  )!
                  as String;
          break;
        case 'image_url':
          result.imageUrl =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(String),
                  )!
                  as String;
          break;
        case 'current_price_usd':
          result.price =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(double),
                  )
                  as double?;
          break;
        case 'price_change_24h_pct':
          result.change24h =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(double),
                  )
                  as double?;
          break;
        case 'volume_24h_usd':
          result.volume24h =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(double),
                  )
                  as double?;
          break;
        case 'market_cap_usd':
          result.marketCap =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(double),
                  )
                  as double?;
          break;
        case 'circulating_supply':
          result.circulating =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(double),
                  )
                  as double?;
          break;
        case 'total_supply':
          result.total =
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
      }
    }

    return result.build();
  }
}

class _$Coin extends Coin {
  @override
  final int id;
  @override
  final String symbol;
  @override
  final String name;
  @override
  final String imageUrl;
  @override
  final double? price;
  @override
  final double? change24h;
  @override
  final double? volume24h;
  @override
  final double? marketCap;
  @override
  final double? circulating;
  @override
  final double? total;
  @override
  final bool isStale;

  factory _$Coin([void Function(CoinBuilder)? updates]) =>
      (CoinBuilder()..update(updates))._build();

  _$Coin._({
    required this.id,
    required this.symbol,
    required this.name,
    required this.imageUrl,
    this.price,
    this.change24h,
    this.volume24h,
    this.marketCap,
    this.circulating,
    this.total,
    required this.isStale,
  }) : super._();
  @override
  Coin rebuild(void Function(CoinBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  CoinBuilder toBuilder() => CoinBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is Coin &&
        id == other.id &&
        symbol == other.symbol &&
        name == other.name &&
        imageUrl == other.imageUrl &&
        price == other.price &&
        change24h == other.change24h &&
        volume24h == other.volume24h &&
        marketCap == other.marketCap &&
        circulating == other.circulating &&
        total == other.total &&
        isStale == other.isStale;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, symbol.hashCode);
    _$hash = $jc(_$hash, name.hashCode);
    _$hash = $jc(_$hash, imageUrl.hashCode);
    _$hash = $jc(_$hash, price.hashCode);
    _$hash = $jc(_$hash, change24h.hashCode);
    _$hash = $jc(_$hash, volume24h.hashCode);
    _$hash = $jc(_$hash, marketCap.hashCode);
    _$hash = $jc(_$hash, circulating.hashCode);
    _$hash = $jc(_$hash, total.hashCode);
    _$hash = $jc(_$hash, isStale.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'Coin')
          ..add('id', id)
          ..add('symbol', symbol)
          ..add('name', name)
          ..add('imageUrl', imageUrl)
          ..add('price', price)
          ..add('change24h', change24h)
          ..add('volume24h', volume24h)
          ..add('marketCap', marketCap)
          ..add('circulating', circulating)
          ..add('total', total)
          ..add('isStale', isStale))
        .toString();
  }
}

class CoinBuilder implements Builder<Coin, CoinBuilder> {
  _$Coin? _$v;

  int? _id;
  int? get id => _$this._id;
  set id(int? id) => _$this._id = id;

  String? _symbol;
  String? get symbol => _$this._symbol;
  set symbol(String? symbol) => _$this._symbol = symbol;

  String? _name;
  String? get name => _$this._name;
  set name(String? name) => _$this._name = name;

  String? _imageUrl;
  String? get imageUrl => _$this._imageUrl;
  set imageUrl(String? imageUrl) => _$this._imageUrl = imageUrl;

  double? _price;
  double? get price => _$this._price;
  set price(double? price) => _$this._price = price;

  double? _change24h;
  double? get change24h => _$this._change24h;
  set change24h(double? change24h) => _$this._change24h = change24h;

  double? _volume24h;
  double? get volume24h => _$this._volume24h;
  set volume24h(double? volume24h) => _$this._volume24h = volume24h;

  double? _marketCap;
  double? get marketCap => _$this._marketCap;
  set marketCap(double? marketCap) => _$this._marketCap = marketCap;

  double? _circulating;
  double? get circulating => _$this._circulating;
  set circulating(double? circulating) => _$this._circulating = circulating;

  double? _total;
  double? get total => _$this._total;
  set total(double? total) => _$this._total = total;

  bool? _isStale;
  bool? get isStale => _$this._isStale;
  set isStale(bool? isStale) => _$this._isStale = isStale;

  CoinBuilder() {
    Coin._initializeBuilder(this);
  }

  CoinBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _symbol = $v.symbol;
      _name = $v.name;
      _imageUrl = $v.imageUrl;
      _price = $v.price;
      _change24h = $v.change24h;
      _volume24h = $v.volume24h;
      _marketCap = $v.marketCap;
      _circulating = $v.circulating;
      _total = $v.total;
      _isStale = $v.isStale;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(Coin other) {
    _$v = other as _$Coin;
  }

  @override
  void update(void Function(CoinBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  Coin build() => _build();

  _$Coin _build() {
    final _$result =
        _$v ??
        _$Coin._(
          id: BuiltValueNullFieldError.checkNotNull(id, r'Coin', 'id'),
          symbol: BuiltValueNullFieldError.checkNotNull(
            symbol,
            r'Coin',
            'symbol',
          ),
          name: BuiltValueNullFieldError.checkNotNull(name, r'Coin', 'name'),
          imageUrl: BuiltValueNullFieldError.checkNotNull(
            imageUrl,
            r'Coin',
            'imageUrl',
          ),
          price: price,
          change24h: change24h,
          volume24h: volume24h,
          marketCap: marketCap,
          circulating: circulating,
          total: total,
          isStale: BuiltValueNullFieldError.checkNotNull(
            isStale,
            r'Coin',
            'isStale',
          ),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
