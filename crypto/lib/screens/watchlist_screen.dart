import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/auth_store.dart';
import '../providers/watchlist_provider.dart';
import '../widgets/coin_tile.dart';
import '../widgets/primitives.dart';
import '../widgets/state_views.dart';

class WatchlistScreen extends StatefulWidget {
  const WatchlistScreen({super.key});
  @override
  State<WatchlistScreen> createState() => _WatchlistScreenState();
}

class _WatchlistScreenState extends State<WatchlistScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => context.read<WatchlistProvider>().refresh());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Watchlist'),
        actions: [IconButton(icon: const Icon(Icons.logout), onPressed: () => context.read<AuthStore>().logout())],
      ),
      body: Consumer<WatchlistProvider>(
        builder: (_, w, __) {
          if (w.loading && w.items.isEmpty) return const LoadingView();
          if (w.items.isEmpty && w.error.isNotEmpty) {
            return ErrorView(message: w.error, onRetry: w.refresh);
          }
          if (w.items.isEmpty) {
            return const EmptyView(message: 'No starred coins yet.\nStar a coin from the Coins tab.');
          }
          return AppRefreshIndicator(
            onRefresh: w.refresh,
            child: ListView(
              children: [
                MaybeOfflineBadge(offline: w.offline, savedAt: w.savedAt),
                ...w.items.map((c) => CoinTile(coin: c)),
              ],
            ),
          );
        },
      ),
    );
  }
}
