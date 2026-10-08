import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/api_client.dart';
import '../core/cache_store.dart';
import '../providers/market_provider.dart';
import '../widgets/coin_tile.dart';
import '../widgets/primitives.dart';
import '../widgets/state_views.dart';

/// Dedicated search tab with its own provider instance.
class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => MarketProvider(context.read<ApiClient>(), context.read<CacheStore>()),
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
    return Scaffold(
      body: SafeArea(
        child: Consumer<MarketProvider>(
          builder: (_, m, __) => Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: AppTextField(
                  controller: _controller,
                  label: 'Search coins',
                  icon: Icons.search,
                  textInputAction: TextInputAction.search,
                  onChanged: m.onSearch,
                ),
              ),
              Expanded(child: _results(m)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _results(MarketProvider m) {
    switch (m.state) {
      case LoadState.idle:
        return const EmptyView(message: 'Type to search all coins.');
      case LoadState.loading:
        return const LoadingView();
      case LoadState.error:
        return ErrorView(message: m.error, onRetry: () => m.refresh(live: false));
      case LoadState.empty:
        return const EmptyView(message: 'No coins match your search.');
      case LoadState.loaded:
        return AppRefreshIndicator(
          onRefresh: () => m.refresh(live: false),
          child: ListView(
            children: [
              MaybeOfflineBadge(offline: m.offline, savedAt: m.savedAt),
              ...[for (var i = 0; i < m.coins.length; i++) CoinTile(coin: m.coins[i], rank: i + 1)],
              const SizedBox(height: 16),
            ],
          ),
        );
    }
  }
}
