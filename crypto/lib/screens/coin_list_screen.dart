import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/market.dart';
import '../providers/market_provider.dart';
import '../screens/coin_detail_screen.dart';
import '../theme/app_theme.dart';
import '../widgets/primitives.dart';
import '../utils/format.dart';
import '../widgets/coin_tile.dart';
import '../widgets/market_overview_card.dart';
import '../widgets/state_views.dart';

/// Home "Market" tab: header, trending cards, overview card, top coins.
class CoinListScreen extends StatelessWidget {
  const CoinListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Consumer<MarketProvider>(
          builder: (_, m, __) => AppRefreshIndicator(
            onRefresh: () => m.refresh(live: true),
            child: _scroll(m),
          ),
        ),
      ),
    );
  }

  Widget _scroll(MarketProvider m) {
    return ListView(
      children: [
        _header(m),
        const SectionTitle(text: 'Trending Coins', top: 4),
        _trending(m),
        const SizedBox(height: 8),
        const MarketOverviewCard(),
        Row(
          children: [
            const Expanded(child: SectionTitle(text: 'Top Coins')),
            PopupMenuButton<String>(
              icon: const Icon(Icons.sort, color: AppColors.muted),
              onSelected: m.setOrdering,
              itemBuilder: (_) => const [
                PopupMenuItem(value: '-market_cap_usd', child: Text('Market cap ↓')),
                PopupMenuItem(value: '-current_price_usd', child: Text('Price ↓')),
                PopupMenuItem(value: '-price_change_24h_pct', child: Text('Top gainers')),
                PopupMenuItem(value: 'symbol', child: Text('A–Z')),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: FilterChip(
                  label: const Text('Gainers'), selected: m.gainersOnly, onSelected: m.setGainers),
            ),
          ],
        ),
        _list(m),
      ],
    );
  }

  Widget _header(MarketProvider m) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Text('Last update', style: TextStyle(color: AppColors.muted, fontSize: 12)),
              Text(m.savedAt == null ? '—' : fmtTime(m.savedAt!),
                  style: const TextStyle(fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _trending(MarketProvider m) {
    if (m.state == LoadState.loading || m.state == LoadState.idle) {
      return const SizedBox(
        height: 120,
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (m.coins.isEmpty) return const SizedBox.shrink();
    final trending = [...m.coins]
      ..sort((a, b) => (b.change24h ?? -999).compareTo(a.change24h ?? -999));
    final top3 = trending.take(3).toList();
    return SizedBox(
      height: 124,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: top3.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (_, i) => _trendingCard(top3[i]),
      ),
    );
  }

  Widget _trendingCard(Coin coin) {
    return Builder(builder: (context) {
      return SizedBox(
        width: 150,
        child: Card(
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: () => Navigator.of(context)
                .push(MaterialPageRoute(builder: (_) => CoinDetailScreen(coin: coin))),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CoinAvatar(imageUrl: coin.imageUrl, size: 34),
                  const SizedBox(height: 6),
                  Text(coin.name, maxLines: 1, overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w500)),
                  const SizedBox(height: 2),
                  Text(coin.symbol, style: const TextStyle(color: AppColors.muted, fontSize: 12)),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }

  Widget _list(MarketProvider m) {
    switch (m.state) {
      case LoadState.loading:
      case LoadState.idle:
        return const LoadingView();
      case LoadState.error:
        return SizedBox(height: 300, child: ErrorView(message: m.error, onRetry: () => m.refresh(live: true)));
      case LoadState.empty:
        return const SizedBox(
            height: 300, child: EmptyView(message: 'No coins found. Pull to retry.'));
      case LoadState.loaded:
        return Column(
          children: [
            MaybeOfflineBadge(offline: m.offline, savedAt: m.savedAt),
            ...[for (var i = 0; i < m.coins.length; i++) CoinTile(coin: m.coins[i], rank: i + 1)],
            const SizedBox(height: 16),
          ],
        );
    }
  }
}
