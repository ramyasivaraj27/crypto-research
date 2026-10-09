// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'watchlist_state.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$WatchlistState extends WatchlistState {
  @override
  final bool loading;
  @override
  final String error;
  @override
  final BuiltList<Coin> items;
  @override
  final DateTime? savedAt;
  @override
  final bool offline;
  @override
  final int page;
  @override
  final int totalPages;
  @override
  final bool loadingMore;
  @override
  final String pageError;

  factory _$WatchlistState([void Function(WatchlistStateBuilder)? updates]) =>
      (WatchlistStateBuilder()..update(updates))._build();

  _$WatchlistState._({
    required this.loading,
    required this.error,
    required this.items,
    this.savedAt,
    required this.offline,
    required this.page,
    required this.totalPages,
    required this.loadingMore,
    required this.pageError,
  }) : super._();
  @override
  WatchlistState rebuild(void Function(WatchlistStateBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  WatchlistStateBuilder toBuilder() => WatchlistStateBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is WatchlistState &&
        loading == other.loading &&
        error == other.error &&
        items == other.items &&
        savedAt == other.savedAt &&
        offline == other.offline &&
        page == other.page &&
        totalPages == other.totalPages &&
        loadingMore == other.loadingMore &&
        pageError == other.pageError;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, loading.hashCode);
    _$hash = $jc(_$hash, error.hashCode);
    _$hash = $jc(_$hash, items.hashCode);
    _$hash = $jc(_$hash, savedAt.hashCode);
    _$hash = $jc(_$hash, offline.hashCode);
    _$hash = $jc(_$hash, page.hashCode);
    _$hash = $jc(_$hash, totalPages.hashCode);
    _$hash = $jc(_$hash, loadingMore.hashCode);
    _$hash = $jc(_$hash, pageError.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'WatchlistState')
          ..add('loading', loading)
          ..add('error', error)
          ..add('items', items)
          ..add('savedAt', savedAt)
          ..add('offline', offline)
          ..add('page', page)
          ..add('totalPages', totalPages)
          ..add('loadingMore', loadingMore)
          ..add('pageError', pageError))
        .toString();
  }
}

class WatchlistStateBuilder
    implements Builder<WatchlistState, WatchlistStateBuilder> {
  _$WatchlistState? _$v;

  bool? _loading;
  bool? get loading => _$this._loading;
  set loading(bool? loading) => _$this._loading = loading;

  String? _error;
  String? get error => _$this._error;
  set error(String? error) => _$this._error = error;

  ListBuilder<Coin>? _items;
  ListBuilder<Coin> get items => _$this._items ??= ListBuilder<Coin>();
  set items(ListBuilder<Coin>? items) => _$this._items = items;

  DateTime? _savedAt;
  DateTime? get savedAt => _$this._savedAt;
  set savedAt(DateTime? savedAt) => _$this._savedAt = savedAt;

  bool? _offline;
  bool? get offline => _$this._offline;
  set offline(bool? offline) => _$this._offline = offline;

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

  WatchlistStateBuilder() {
    WatchlistState._initializeBuilder(this);
  }

  WatchlistStateBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _loading = $v.loading;
      _error = $v.error;
      _items = $v.items.toBuilder();
      _savedAt = $v.savedAt;
      _offline = $v.offline;
      _page = $v.page;
      _totalPages = $v.totalPages;
      _loadingMore = $v.loadingMore;
      _pageError = $v.pageError;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(WatchlistState other) {
    _$v = other as _$WatchlistState;
  }

  @override
  void update(void Function(WatchlistStateBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  WatchlistState build() => _build();

  _$WatchlistState _build() {
    _$WatchlistState _$result;
    try {
      _$result =
          _$v ??
          _$WatchlistState._(
            loading: BuiltValueNullFieldError.checkNotNull(
              loading,
              r'WatchlistState',
              'loading',
            ),
            error: BuiltValueNullFieldError.checkNotNull(
              error,
              r'WatchlistState',
              'error',
            ),
            items: items.build(),
            savedAt: savedAt,
            offline: BuiltValueNullFieldError.checkNotNull(
              offline,
              r'WatchlistState',
              'offline',
            ),
            page: BuiltValueNullFieldError.checkNotNull(
              page,
              r'WatchlistState',
              'page',
            ),
            totalPages: BuiltValueNullFieldError.checkNotNull(
              totalPages,
              r'WatchlistState',
              'totalPages',
            ),
            loadingMore: BuiltValueNullFieldError.checkNotNull(
              loadingMore,
              r'WatchlistState',
              'loadingMore',
            ),
            pageError: BuiltValueNullFieldError.checkNotNull(
              pageError,
              r'WatchlistState',
              'pageError',
            ),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'items';
        items.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
          r'WatchlistState',
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
