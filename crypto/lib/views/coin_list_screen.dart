import 'package:flutter/material.dart';

import '../model/coin.dart';
import '../model/load_state.dart';
import '../model/market_state.dart';
import '../provider/provider_utils.dart';
import '../theme/app_theme.dart';
import '../utils/format.dart';
import '../view_model/market_view_model.dart';
import '../widgets/coin_tile.dart';
import '../widgets/market_overview_card.dart';
import '../widgets/pagination.dart';
import '../widgets/primitives.dart';
import '../widgets/state_views.dart';
import 'coin_detail_screen.dart';

/// Home "Market" tab: header, trending cards, overview card, top coins.
class CoinListScreen extends StatelessWidget {
  const CoinListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final s = context.marketState;
    final vm = context.marketViewModel;
    return Scaffold(
      body: SafeArea(
        child: AppRefreshIndicator(
          onRefresh: () => vm.refresh(live: true),
          child: _scroll(s, vm),
        ),
      ),
    );
  }

  Widget _scroll(MarketState s, MarketViewModel vm) {
    // Stale-while-revalidate: when rows are already loaded, a refresh keeps
    // rendering them instead of swapping in a skeleton, so an in-flight
    // interaction is never left pointing at an unmounted subtree.
    if ((s.status == LoadState.loading || s.status == LoadState.idle) && s.coins.isEmpty) {
      return const LoadingView();
    }
    if (s.status == LoadState.error && s.coins.isEmpty) {
      return ErrorView(message: s.error, onRetry: () => vm.refresh(live: true));
    }
    if (s.status == LoadState.empty && s.coins.isEmpty) {
      return const EmptyView(message: 'No coins found. Pull to retry.');
    }
    return PagedListView(
      onLoadMore: vm.loadMore,
      itemCount: s.coins.length,
      itemBuilder: (_, i) => CoinTile(coin: s.coins[i], rank: i + 1),
      prefix: [
        _header(s),
        if (s.status == LoadState.loading && s.coins.isNotEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: LinearProgressIndicator(minHeight: 2),
          ),
        const SectionTitle(text: 'Trending Coins', top: 4),
        _trending(s),
        const SizedBox(height: 8),
        const MarketOverviewCard(),
        Row(
          children: [
            const Expanded(child: SectionTitle(text: 'Top Coins')),
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: FilterChip(
                  label: const Text('Gainers'), selected: s.gainersOnly, onSelected: vm.setGainers),
            ),
          ],
        ),
        _sortStrip(s, vm),
        MaybeOfflineBadge(offline: s.offline, savedAt: s.savedAt),
      ],
      suffix: [
        LoadMoreFooter(
          hasNext: s.hasNext,
          loadingMore: s.loadingMore,
          pageError: s.pageError,
          onRetry: vm.loadMore,
        ),
      ],
    );
  }

  Widget _header(MarketState s) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Text('Last update', style: TextStyle(color: AppColors.muted, fontSize: 12)),
              Text(s.savedAt == null ? '—' : fmtTime(s.savedAt!),
                  style: const TextStyle(fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }

  static const _sortOptions = [
    ('-market_cap_usd', 'Market cap'),
    ('-current_price_usd', 'Price'),
    ('-price_change_24h_pct', 'Top gainers'),
    ('symbol', 'A–Z'),
  ];

  /// Inline sort chips. Deliberately NOT a PopupMenuButton: the popup keeps an
  /// overlay route holding a raw State reference to its anchor button, and any
  /// rebuild that replaces the anchor (state swap, hot reload) throws
  /// "widget has been unmounted" from PopupMenuButtonState. Chips hold no
  /// cross-frame references, so this crash class cannot recur.
  Widget _sortStrip(MarketState s, MarketViewModel vm) {
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _sortOptions.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final (value, label) = _sortOptions[i];
          return ChoiceChip(
            label: Text(label, style: const TextStyle(fontSize: 12)),
            selected: s.ordering == value,
            onSelected: (_) => vm.setOrdering(value),
          );
        },
      ),
    );
  }

  Widget _trending(MarketState s) {
    if (s.status == LoadState.loading || s.status == LoadState.idle) {
      return const SizedBox(
        height: 120,
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (s.coins.isEmpty) return const SizedBox.shrink();
    final trending = [...s.coins]
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
}
