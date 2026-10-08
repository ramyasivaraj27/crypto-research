import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/market_provider.dart';
import '../utils/format.dart';
import '../widgets/coin_tile.dart';
import '../widgets/state_views.dart';

class CoinListScreen extends StatelessWidget {
  const CoinListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Coins')),
      body: Consumer<MarketProvider>(
        builder: (_, m, __) => Column(
          children: [
            if (m.offline && m.savedAt != null) OfflineBadge(savedAgo: fmtAgo(m.savedAt)),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      decoration: const InputDecoration(prefixIcon: Icon(Icons.search), hintText: 'Search coins', border: OutlineInputBorder()),
                      onChanged: m.onSearch,
                    ),
                  ),
                  const SizedBox(width: 8),
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.sort),
                    onSelected: m.setOrdering,
                    itemBuilder: (_) => const [
                      PopupMenuItem(value: '-market_cap_usd', child: Text('Market cap ↓')),
                      PopupMenuItem(value: '-current_price_usd', child: Text('Price ↓')),
                      PopupMenuItem(value: '-price_change_24h_pct', child: Text('Top gainers')),
                      PopupMenuItem(value: 'symbol', child: Text('A–Z')),
                    ],
                  ),
                  FilterChip(label: const Text('Gainers'), selected: m.gainersOnly, onSelected: m.setGainers),
                ],
              ),
            ),
            Expanded(child: _body(m)),
          ],
        ),
      ),
    );
  }

  Widget _body(MarketProvider m) {
    switch (m.state) {
      case LoadState.loading:
      case LoadState.idle:
        return const LoadingView();
      case LoadState.error:
        return ErrorView(message: m.error, onRetry: m.refresh);
      case LoadState.empty:
        return const EmptyView(message: 'No coins found. Try another search.');
      case LoadState.loaded:
        return RefreshIndicator(
          onRefresh: m.refresh,
          child: ListView.separated(
            itemCount: m.coins.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (_, i) => CoinTile(coin: m.coins[i]),
          ),
        );
    }
  }
}
