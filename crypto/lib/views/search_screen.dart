import 'package:flutter/material.dart';
import 'package:flutter_state_notifier/flutter_state_notifier.dart';
import 'package:provider/provider.dart';

import '../core/api_client.dart';
import '../core/cache_store.dart';
import '../model/load_state.dart';
import '../model/market_state.dart';
import '../provider/provider_utils.dart';
import '../view_model/market_view_model.dart';
import '../widgets/coin_tile.dart';
import '../widgets/pagination.dart';
import '../widgets/primitives.dart';
import '../widgets/state_views.dart';

/// Dedicated search tab with its own view-model instance.
class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return StateNotifierProvider<MarketViewModel, MarketState>(
      create: (_) => MarketViewModel(context.read<ApiClient>(), context.read<CacheStore>()),
      child: const _SearchBody(),
    );
  }
}

class _SearchBody extends StatefulWidget {
  const _SearchBody();

  @override
  State<_SearchBody> createState() => _SearchBodyState();
}

class _SearchBodyState extends State<_SearchBody> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = context.marketState;
    final vm = context.marketViewModel;
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: AppTextField(
                controller: _controller,
                label: 'Search coins',
                icon: Icons.search,
                textInputAction: TextInputAction.search,
                onChanged: vm.onSearch,
              ),
            ),
            Expanded(child: _results(s, vm)),
          ],
        ),
      ),
    );
  }

  Widget _results(MarketState s, MarketViewModel vm) {
    switch (s.status) {
      case LoadState.idle:
        return const EmptyView(message: 'Type to search all coins.');
      case LoadState.loading:
        return const LoadingView();
      case LoadState.error:
        return ErrorView(message: s.error, onRetry: () => vm.refresh(live: false));
      case LoadState.empty:
        return const EmptyView(message: 'No coins match your search.');
      case LoadState.loaded:
        return AppRefreshIndicator(
          onRefresh: () => vm.refresh(live: false),
          child: PagedListView(
            onLoadMore: vm.loadMore,
            itemCount: s.coins.length,
            itemBuilder: (_, i) => CoinTile(coin: s.coins[i], rank: i + 1),
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
    }
  }
}
