// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'market_state.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$MarketState extends MarketState {
  @override
  final LoadState status;
  @override
  final BuiltList<Coin> coins;
  @override
  final String error;
  @override
  final DateTime? savedAt;
  @override
  final bool offline;
  @override
  final String search;
  @override
  final String ordering;
  @override
  final bool gainersOnly;
  @override
  final int page;
  @override
  final int totalPages;
  @override
  final bool loadingMore;
  @override
  final String pageError;

  factory _$MarketState([void Function(MarketStateBuilder)? updates]) =>
      (MarketStateBuilder()..update(updates))._build();

  _$MarketState._({
    required this.status,
    required this.coins,
    required this.error,
    this.savedAt,
    required this.offline,
    required this.search,
    required this.ordering,
    required this.gainersOnly,
    required this.page,
    required this.totalPages,
    required this.loadingMore,
    required this.pageError,
  }) : super._();
  @override
  MarketState rebuild(void Function(MarketStateBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  MarketStateBuilder toBuilder() => MarketStateBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is MarketState &&
        status == other.status &&
        coins == other.coins &&
        error == other.error &&
        savedAt == other.savedAt &&
        offline == other.offline &&
        search == other.search &&
        ordering == other.ordering &&
        gainersOnly == other.gainersOnly &&
        page == other.page &&
        totalPages == other.totalPages &&
        loadingMore == other.loadingMore &&
        pageError == other.pageError;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, status.hashCode);
    _$hash = $jc(_$hash, coins.hashCode);
    _$hash = $jc(_$hash, error.hashCode);
    _$hash = $jc(_$hash, savedAt.hashCode);
    _$hash = $jc(_$hash, offline.hashCode);
    _$hash = $jc(_$hash, search.hashCode);
    _$hash = $jc(_$hash, ordering.hashCode);
    _$hash = $jc(_$hash, gainersOnly.hashCode);
    _$hash = $jc(_$hash, page.hashCode);
    _$hash = $jc(_$hash, totalPages.hashCode);
    _$hash = $jc(_$hash, loadingMore.hashCode);
    _$hash = $jc(_$hash, pageError.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'MarketState')
          ..add('status', status)
          ..add('coins', coins)
          ..add('error', error)
          ..add('savedAt', savedAt)
          ..add('offline', offline)
          ..add('search', search)
          ..add('ordering', ordering)
          ..add('gainersOnly', gainersOnly)
          ..add('page', page)
          ..add('totalPages', totalPages)
          ..add('loadingMore', loadingMore)
          ..add('pageError', pageError))
        .toString();
  }
}

class MarketStateBuilder implements Builder<MarketState, MarketStateBuilder> {
  _$MarketState? _$v;

  LoadState? _status;
  LoadState? get status => _$this._status;
  set status(LoadState? status) => _$this._status = status;

  ListBuilder<Coin>? _coins;
  ListBuilder<Coin> get coins => _$this._coins ??= ListBuilder<Coin>();
  set coins(ListBuilder<Coin>? coins) => _$this._coins = coins;

  String? _error;
  String? get error => _$this._error;
  set error(String? error) => _$this._error = error;

  DateTime? _savedAt;
  DateTime? get savedAt => _$this._savedAt;
  set savedAt(DateTime? savedAt) => _$this._savedAt = savedAt;

  bool? _offline;
  bool? get offline => _$this._offline;
  set offline(bool? offline) => _$this._offline = offline;

  String? _search;
  String? get search => _$this._search;
  set search(String? search) => _$this._search = search;

  String? _ordering;
  String? get ordering => _$this._ordering;
  set ordering(String? ordering) => _$this._ordering = ordering;

  bool? _gainersOnly;
  bool? get gainersOnly => _$this._gainersOnly;
  set gainersOnly(bool? gainersOnly) => _$this._gainersOnly = gainersOnly;

  int? _page;
  int? get page => _$this._page;
  set page(int? page) => _$this._page = page;

  int? _totalPages;
  int? get totalPages => _$this._totalPages;
  set totalPages(int? totalPages) => _$this._totalPages = totalPages;

  bool? _loadingMore;
  bool? get loadingMore => _$this._loadingMore;
  set loadingMore(bool? loadingMore) => _$this._loadingMore = loadingMore;

  String? _pageError;
  String? get pageError => _$this._pageError;
  set pageError(String? pageError) => _$this._pageError = pageError;

  MarketStateBuilder() {
    MarketState._initializeBuilder(this);
  }

  MarketStateBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _status = $v.status;
      _coins = $v.coins.toBuilder();
      _error = $v.error;
      _savedAt = $v.savedAt;
      _offline = $v.offline;
      _search = $v.search;
      _ordering = $v.ordering;
      _gainersOnly = $v.gainersOnly;
      _page = $v.page;
      _totalPages = $v.totalPages;
      _loadingMore = $v.loadingMore;
      _pageError = $v.pageError;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(MarketState other) {
    _$v = other as _$MarketState;
  }

  @override
  void update(void Function(MarketStateBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  MarketState build() => _build();

  _$MarketState _build() {
    _$MarketState _$result;
    try {
      _$result =
          _$v ??
          _$MarketState._(
            status: BuiltValueNullFieldError.checkNotNull(
              status,
              r'MarketState',
              'status',
            ),
            coins: coins.build(),
            error: BuiltValueNullFieldError.checkNotNull(
              error,
              r'MarketState',
              'error',
            ),
            savedAt: savedAt,
            offline: BuiltValueNullFieldError.checkNotNull(
              offline,
              r'MarketState',
              'offline',
            ),
            search: BuiltValueNullFieldError.checkNotNull(
              search,
              r'MarketState',
              'search',
            ),
            ordering: BuiltValueNullFieldError.checkNotNull(
              ordering,
              r'MarketState',
              'ordering',
            ),
            gainersOnly: BuiltValueNullFieldError.checkNotNull(
              gainersOnly,
              r'MarketState',
              'gainersOnly',
            ),
            page: BuiltValueNullFieldError.checkNotNull(
              page,
              r'MarketState',
              'page',
            ),
            totalPages: BuiltValueNullFieldError.checkNotNull(
              totalPages,
              r'MarketState',
              'totalPages',
            ),
            loadingMore: BuiltValueNullFieldError.checkNotNull(
              loadingMore,
              r'MarketState',
              'loadingMore',
            ),
            pageError: BuiltValueNullFieldError.checkNotNull(
              pageError,
              r'MarketState',
              'pageError',
            ),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'coins';
        coins.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
          r'MarketState',
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
