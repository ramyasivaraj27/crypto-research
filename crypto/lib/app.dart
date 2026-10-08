import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/api_client.dart';
import '../core/auth_store.dart';
import '../core/cache_store.dart';
import '../providers/market_provider.dart';
import '../providers/watchlist_provider.dart';
import '../theme/app_theme.dart';
import 'screens/coin_list_screen.dart';
import 'screens/login_screen.dart';
import 'screens/search_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/watchlist_screen.dart';

class CryptoApp extends StatefulWidget {
  const CryptoApp({super.key});

  @override
  State<CryptoApp> createState() => _CryptoAppState();
}

class _CryptoAppState extends State<CryptoApp> {
  late final ApiClient api;
  late final AuthStore auth;
  late final CacheStore cache;
  int _tab = 0;

  @override
  void initState() {
    super.initState();
    api = ApiClient();
    auth = AuthStore(api)..load();
    cache = CacheStore();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: auth),
        Provider.value(value: api),
        Provider.value(value: cache),
        ChangeNotifierProvider(create: (_) => MarketProvider(api, cache)..refresh(live: false)),
        ChangeNotifierProvider(create: (_) => WatchlistProvider(api, auth, cache)),
      ],
      child: MaterialApp(
        title: 'Crypto Research',
        theme: buildDarkTheme(),
        home: _tabs(),
      ),
    );
  }

  Widget _tabs() {
    final pages = [
      const CoinListScreen(),
      Consumer<AuthStore>(
        builder: (_, auth, __) => auth.isLoggedIn ? const WatchlistScreen() : const LoginScreen(),
      ),
      const SearchScreen(),
      const SettingsScreen(),
    ];
    return Scaffold(
      body: IndexedStack(index: _tab, children: pages),
      bottomNavigationBar: _bottomBar(),
    );
  }

  Widget _bottomBar() {
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
                onTap: () => setState(() => _tab = i),
                behavior: HitTestBehavior.opaque,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
                      decoration: BoxDecoration(
                        color: _tab == i ? AppColors.selectedPill : Colors.transparent,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Icon(items[i].$1,
                          color: _tab == i ? Colors.white : AppColors.muted),
                    ),
                    const SizedBox(height: 2),
                    Text(items[i].$2,
                        style: TextStyle(
                            fontSize: 11,
                            color: _tab == i ? Colors.white : AppColors.muted)),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
