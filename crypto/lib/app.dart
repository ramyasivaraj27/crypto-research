import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/api_client.dart';
import 'core/auth_store.dart';
import 'core/cache_store.dart';
import 'providers/market_provider.dart';
import 'providers/watchlist_provider.dart';
import 'screens/coin_list_screen.dart';
import 'screens/login_screen.dart';
import 'screens/market_stats_screen.dart';
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
        ChangeNotifierProvider(create: (_) => MarketProvider(api, cache)..refresh()),
        ChangeNotifierProvider(create: (_) => WatchlistProvider(api, auth, cache)),
      ],
      child: MaterialApp(
        title: 'Crypto Research',
        theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple), useMaterial3: true),
        home: _tabs(),
      ),
    );
  }

  Widget _tabs() {
    final pages = [
      const CoinListScreen(),
      const MarketStatsScreen(),
      Consumer<AuthStore>(
        builder: (_, auth, __) => auth.isLoggedIn ? const WatchlistScreen() : const LoginScreen(),
      ),
    ];
    return Scaffold(
      body: IndexedStack(index: _tab, children: pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tab,
        onDestinationSelected: (i) => setState(() => _tab = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.list), label: 'Coins'),
          NavigationDestination(icon: Icon(Icons.bar_chart), label: 'Market'),
          NavigationDestination(icon: Icon(Icons.star), label: 'Watchlist'),
        ],
      ),
    );
  }
}
