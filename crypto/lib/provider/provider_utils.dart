import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import '../model/app_state.dart';
import '../model/auth_state.dart';
import '../model/market_state.dart';
import '../model/watchlist_state.dart';
import '../view_model/app_view_model.dart';
import '../view_model/auth_view_model.dart';
import '../view_model/market_view_model.dart';
import '../view_model/watchlist_view_model.dart';

/// Typed provider accessors (mirrors balm's provider_utils):
/// `read<XViewModel>()` for actions, `watch<XState>()` for rebuilds.
extension ProviderUtils on BuildContext {
  AppViewModel get appViewModel => read<AppViewModel>();
  MarketViewModel get marketViewModel => read<MarketViewModel>();
  WatchlistViewModel get watchlistViewModel => read<WatchlistViewModel>();
  AuthViewModel get authViewModel => read<AuthViewModel>();

  AppState get appState => watch<AppState>();
  MarketState get marketState => watch<MarketState>();
  WatchlistState get watchlistState => watch<WatchlistState>();
  AuthState get authState => watch<AuthState>();
}
