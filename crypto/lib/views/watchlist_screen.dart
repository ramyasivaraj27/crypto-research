import 'package:flutter/material.dart';

import '../provider/provider_utils.dart';
import '../widgets/coin_tile.dart';
import '../widgets/pagination.dart';
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
    WidgetsBinding.instance.addPostFrameCallback((_) => context.watchlistViewModel.refresh());
  }

  @override
  Widget build(BuildContext context) {
    final s = context.watchlistState;
    final vm = context.watchlistViewModel;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Watchlist'),
        actions: [IconButton(icon: const Icon(Icons.logout), onPressed: () => context.authViewModel.logout())],
      ),
      body: Builder(
        builder: (_) {
          if (s.loading && s.items.isEmpty) return const LoadingView();
          if (s.items.isEmpty && s.error.isNotEmpty) {
            return ErrorView(message: s.error, onRetry: vm.refresh);
          }
          if (s.items.isEmpty) {
            return const EmptyView(message: 'No starred coins yet.\nStar a coin from the Coins tab.');
          }
          return AppRefreshIndicator(
            onRefresh: vm.refresh,
            child: PagedListView(
              onLoadMore: vm.loadMore,
              itemCount: s.items.length,
              itemBuilder: (_, i) => CoinTile(coin: s.items[i]),
              prefix: [MaybeOfflineBadge(offline: s.offline, savedAt: s.savedAt)],
              suffix: [
                LoadMoreFooter(
                  hasNext: s.hasNext,
                  loadingMore: s.loadingMore,
                  pageError: s.pageError,
                  onRetry: vm.loadMore,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
