// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'price_point.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

Serializer<PricePoint> _$pricePointSerializer = _$PricePointSerializer();

class _$PricePointSerializer implements StructuredSerializer<PricePoint> {
  @override
  final Iterable<Type> types = const [PricePoint, _$PricePoint];
  @override
  final String wireName = 'PricePoint';

  @override
  Iterable<Object?> serialize(
    Serializers serializers,
    PricePoint object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = <Object?>[
      't',
      serializers.serialize(object.t, specifiedType: const FullType(DateTime)),
      'price',
      serializers.serialize(
        object.price,
        specifiedType: const FullType(double),
      ),
    ];

    return result;
  }

  @override
  PricePoint deserialize(
    Serializers serializers,
    Iterable<Object?> serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PricePointBuilder();

    final iterator = serialized.iterator;
    while (iterator.moveNext()) {
      final key = iterator.current! as String;
      iterator.moveNext();
      final Object? value = iterator.current;
      switch (key) {
        case 't':
          result.t =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(DateTime),
                  )!
                  as DateTime;
          break;
        case 'price':
          result.price =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(double),
                  )!
                  as double;
          break;
      }
    }

    return result.build();
  }
}

class _$PricePoint extends PricePoint {
  @override
  final DateTime t;
  @override
  final double price;

  factory _$PricePoint([void Function(PricePointBuilder)? updates]) =>
      (PricePointBuilder()..update(updates))._build();

  _$PricePoint._({required this.t, required this.price}) : super._();
  @override
  PricePoint rebuild(void Function(PricePointBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PricePointBuilder toBuilder() => PricePointBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PricePoint && t == other.t && price == other.price;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, t.hashCode);
    _$hash = $jc(_$hash, price.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'PricePoint')
          ..add('t', t)
          ..add('price', price))
        .toString();
  }
}

class PricePointBuilder implements Builder<PricePoint, PricePointBuilder> {
  _$PricePoint? _$v;

  DateTime? _t;
  DateTime? get t => _$this._t;
  set t(DateTime? t) => _$this._t = t;

  double? _price;
  double? get price => _$this._price;
  set price(double? price) => _$this._price = price;

  PricePointBuilder();

  PricePointBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _t = $v.t;
      _price = $v.price;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(PricePoint other) {
    _$v = other as _$PricePoint;
  }

  @override
  void update(void Function(PricePointBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  PricePoint build() => _build();

  _$PricePoint _build() {
    final _$result =
        _$v ??
        _$PricePoint._(
          t: BuiltValueNullFieldError.checkNotNull(t, r'PricePoint', 't'),
          price: BuiltValueNullFieldError.checkNotNull(
            price,
            r'PricePoint',
            'price',
          ),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
