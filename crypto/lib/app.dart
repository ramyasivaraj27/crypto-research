import 'package:flutter/material.dart';
import 'package:flutter_state_notifier/flutter_state_notifier.dart';
import 'package:provider/provider.dart';

import 'core/api_client.dart';
import 'core/cache_store.dart';
import 'model/app_state.dart';
import 'model/auth_state.dart';
import 'model/market_state.dart';
import 'model/watchlist_state.dart';
import 'provider/provider_utils.dart';
import 'theme/app_theme.dart';
import 'view_model/app_view_model.dart';
import 'view_model/auth_view_model.dart';
import 'view_model/market_view_model.dart';
import 'view_model/watchlist_view_model.dart';
import 'views/coin_list_screen.dart';
import 'views/login_screen.dart';
import 'views/search_screen.dart';
import 'views/settings_screen.dart';
import 'views/watchlist_screen.dart';

class CryptoApp extends StatefulWidget {
  const CryptoApp({super.key});

  @override
  State<CryptoApp> createState() => _CryptoAppState();
}

class _CryptoAppState extends State<CryptoApp> {
  late final ApiClient api;
  late final AuthViewModel auth;
  late final CacheStore cache;

  @override
  void initState() {
    super.initState();
    api = ApiClient();
    auth = AuthViewModel(api)..init();
    cache = CacheStore();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider.value(value: api),
        Provider.value(value: cache),
        StateNotifierProvider<AppViewModel, AppState>(
          create: (_) => AppViewModel(),
        ),
        StateNotifierProvider<AuthViewModel, AuthState>(
          create: (_) => auth,
        ),
        StateNotifierProvider<MarketViewModel, MarketState>(
          create: (_) => MarketViewModel(api, cache)..init(),
        ),
        StateNotifierProvider<WatchlistViewModel, WatchlistState>(
          create: (_) => WatchlistViewModel(api, auth, cache),
        ),
      ],
      child: MaterialApp(
        title: 'Crypto Research',
        theme: buildDarkTheme(),
        home: const _TabsShell(),
      ),
    );
  }
}

class _TabsShell extends StatelessWidget {
  const _TabsShell();

  @override
  Widget build(BuildContext context) {
    final tab = context.appState.activeIndex;
    final loggedIn = context.authState.isLoggedIn;
    final pages = [
      const CoinListScreen(),
      loggedIn ? const WatchlistScreen() : const LoginScreen(),
      const SearchScreen(),
      const SettingsScreen(),
    ];
    return Scaffold(
      body: IndexedStack(index: tab, children: pages),
      bottomNavigationBar: _bottomBar(context, tab),
    );
  }

  Widget _bottomBar(BuildContext context, int tab) {
    const items = [
      (Icons.show_chart, 'Market'),
      (Icons.star, 'Watchlist'),
      (Icons.search, 'Search'),
      (Icons.settings, 'Settings'),
    ];
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            for (var i = 0; i < items.length; i++)
              GestureDetector(
                onTap: () => context.appViewModel.bottomNavIndex(index: i),
                behavior: HitTestBehavior.opaque,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
                      decoration: BoxDecoration(
                        color: tab == i ? AppColors.selectedPill : Colors.transparent,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Icon(items[i].$1,
                          color: tab == i ? Colors.white : AppColors.muted),
                    ),
                    const SizedBox(height: 2),
                    Text(items[i].$2,
                        style: TextStyle(
                            fontSize: 11,
                            color: tab == i ? Colors.white : AppColors.muted)),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
